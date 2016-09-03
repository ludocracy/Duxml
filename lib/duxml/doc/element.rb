# Copyright (c) 2016 Freescale Semiconductor Inc.

require 'ox'
require File.expand_path(File.dirname(__FILE__) + '/lazy_ox')
require File.expand_path(File.dirname(__FILE__) + '/node_set')
require File.expand_path(File.dirname(__FILE__) + '/../reportable')

module Duxml
  # contains actual methods of XML Element
  module ElementGuts
    include Duxml
    include Enumerable
    include Reportable
    include LazyOx
  end

  # basic component of XML file that can possess attributes and take sub Elements or String content
  class Element < ::Ox::Element
    include ElementGuts

    # line number
    @line

    # column
    @column

    # document to which this Element belongs
    @doc

    # operates in two modes:
    # - from Ruby
    # - from file
    # in file mode, args provide Element's line and column location then freezes each Fixnum so it cannot be overwritten
    # in Ruby mode, args are some combination of new attributes/values and/or child nodes (text or XML) with which to initialize this node
    #
    # @param name [String] name of element, in both Ruby and file modes
    # @param _line_or_content [Fixnum, Array, Hash] line number of element file mode; if Array, new child nodes; if Hash, attributes; can be nil
    # @param _col_or_children [Fixnum, Array] column position in file mode; if Array, new child nodes; can be nil
    # @return [Element] new XML Element
    def initialize(name, _line_or_content=nil, _col_or_children=nil)
      super name
      @line = _line_or_content if _line_or_content.respond_to?(:%)
      _line_or_content.each do |k,v| self[k] = v end if _line_or_content.respond_to?(:key)
      @nodes = NodeSet.new(self, _line_or_content) if _line_or_content.respond_to?(:pop) && _col_or_children.nil?
      @column = _col_or_children if _col_or_children.respond_to?(:%)
      @nodes = NodeSet.new(self, _col_or_children) if _col_or_children.respond_to?(:pop)
      @nodes = NodeSet.new(self) if @nodes.empty?
    end

    attr_reader :line, :column, :doc

    attr_accessor :nodes
  end

  module ElementGuts
    # @return [Boolean] whether or not this has been written to file
    def abstract?
      line < 0 || column < 0
    end

    # @param _doc [Doc] document to which this element belongs - recursively applies to all descendants of this node
    # @return [Element] self
    def set_doc!(_doc)
      @doc = _doc
      traverse do |node|
        next if node === self or node.is_a?(String)
        node.set_doc!(_doc)
      end
      self
    end

    # @see Ox::Element#<<
    # this override reports changes to history; NewText for Strings, Add for elements
    #
    # @param obj [Element, Array] element or string to add to this Element; can insert arrays which are always inserted in order
    # @return [Element] self
    def <<(obj)
      add(obj)
    end

    # @see #<<
    # this version of the method allows insertions between existing elements
    #
    # @param obj [Element, Array] element or string to add to this Element; can insert arrays which are always inserted in order
    # @param index [Fixnum] index at which to insert new node; inserts at end of element by default; when inserting arrays, index is incremented for each item to avoid reversing array order
    # @return [Element] self
    def add(obj, index=-1)
      case
        when obj.is_a?(Array), obj.is_a?(NodeSet)
          obj.each_with_index do |e, i|
            add(e, index == -1 ? index : index+i)
          end
        when obj.is_a?(String)
          if obj[0] == '<' and obj[-1] == '>' and (s = Ox.parse(obj))
            add dclone s
          else
            type = :NewText
            nodes.insert(index, obj)
          end
        else
          type = :Add
          nodes.insert(index, obj)
          if obj.count_observers < 1 && @observer_peers
            obj.add_observer(@observer_peers.first.first)
          end
          obj.set_doc! @doc
      end
      report(type, obj, index)
      self
    end

    # @param index_or_attr [String, Symbol, Fixnum] string or symbol of attribute or index of child node
    # @return [Element, String] string if attribute value or text node; Element if XML node
    def [](index_or_attr)
      index_or_attr.is_a?(Fixnum) ? nodes[index_or_attr] : super(index_or_attr)
    end

    # @param attr_sym [String, Symbol, Fixnum] name of attribute or index of child to replace
    # @param val [String] new attribute value or replacement child node
    # @return [Element] self
    def []=(attr_sym, val)
      if attr_sym.is_a?(Fixnum)
        remove nodes[attr_sym]
        add(val, attr_sym) if val
        return self
      end
      attr = attr_sym.to_s
      raise "argument to [] must be a Symbol or a String." unless attr.is_a?(Symbol) or attr.is_a?(String)
      args = [attr]
      args << attributes[attr] if attributes[attr]
      val.nil? ? @attributes.delete(attr) : super(attr, val)
      type = args.size == 1 ? :NewAttr : :ChangeAttr
      report(type, *args)
      self
    end

    # @return [String] self description
    def description
      "<#{name}>"
    end

    # @return [Element] copy of this Element but with no children
    def stub
      Element.new(name, attributes)
    end

    # @return [HistoryClass] history that is observing this element for changes
    def history
      @observer_peers.first.first if @observer_peers.respond_to?(:any?) and @observer_peers.any? and @observer_peers.first.any?
    end

    # @return [String] XML string (overrides Ox's to_s which just prints the object pointer)
    def to_s
      s = %(<#{name})
      attributes.each do |k,v| s << %( #{k.to_s}="#{v}") end
      return s+'/>' if nodes.empty?
      s << ">#{nodes.collect do |n| n.to_s end.join}</#{name}>"
    end

    # @return #to_s
    def inspect
      to_s
    end

    # TODO do we need this method to take Fixnum node index as well?
    # @param obj [Element] element child to delete
    # @return [Element] deleted element
    def delete(obj)
      report(:Remove, @nodes.delete(obj))
      obj
    end

    alias_method :remove, :delete

    # pre-order traverse through this node and all of its descendants
    #
    # @param &block [block] code to execute for each yielded node
    def traverse(node=nil, &block)
      return self.to_enum unless block_given?
      node_stack = [node || self]

      until node_stack.empty?
        current = node_stack.shift
        if current
          yield current
          node_stack = node_stack.insert(0, *current.nodes) if current.respond_to?(:nodes)
        end
      end

      node || self if block_given?
    end

    # traverse through just the children of this node
    #
    # @param &block [block] code to execute for each child node
    def each(&block)
      @nodes.each(&block)
    end

    # @return [String] namespace of element, derived from name e.g. '<duxml:element>' => 'duxml'
    def name_space
      return nil unless (i = name.index(':'))
      name[0..i-1]
    end


    # @param source [Element] if not explicitly provided, creates deep clone of this element; source can be any XML element (not only Duxml) that responds to traverse with pre-order traversal
    # @return [Element] deep clone of source, including its attributes and recursively cloned children
    def dclone(source = self)
      input_stack = []
      output_stack = []
      traverse(source) do |node|
        if node.is_a?(String)
          output_stack.last << node
          next
        end
        copy = Element.new(node.name, node.attributes)
        if output_stack.empty?
          output_stack << copy
          input_stack << node
        else

          if input_stack.last.nodes.none? do |n| n === node end
            input_stack.pop
            output_stack.pop
          end

          output_stack.last << copy
          if node.nodes.any?
            output_stack << copy
            input_stack << node
          end

        end
      end
      output_stack.pop
    end

    # @return [Element] shallow clone of this element, with all attributes and children only if none are Elements
    def sclone
      stub = Element.new(name, attributes)
      stub << nodes if text?
      stub
    end

    # @return [true, false] true if all child nodes are text only; false if any child nodes are XML
    def text?
      nodes.all? do |node| node.is_a?(String) end
    end
  end # class Element < Node
end # module Ox