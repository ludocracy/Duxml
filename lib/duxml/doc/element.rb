# Copyright (c) 2016 Freescale Semiconductor Inc.

require 'ox'
require File.expand_path(File.dirname(__FILE__) + '/lazy_ox')
require File.expand_path(File.dirname(__FILE__) + '/node_set')
require File.expand_path(File.dirname(__FILE__) + '/../reportable')

module Duxml
  module ElementGuts
    include Duxml
    include Enumerable
    include Reportable
    include LazyOx
  end

  class Element < ::Ox::Element
    include ElementGuts

    # operates in two modes:
    # - from Ruby
    # - from file
    # in file mode, args provide Element's line and column location then freezes each Fixnum so it cannot be overwritten
    # in Ruby mode, args are some combination of new attributes/values and/or child nodes (text or XML) with which to initialize this node
    #
    # @param name [String] name of element, in both Ruby and file modes
    # @param _line_content [Fixnum, Array, Hash] line number of element file mode; if Array, new child nodes; if Hash, attributes; can be nil
    # @param _col_or_children [Fixnum, Array] column position in file mode; if Array, new child nodes; can be nil
    def initialize(name, _line_or_content=nil, _col_or_children=nil)
      super name
      @line = _line_or_content if _line_or_content.respond_to?(:%)
      _line_or_content.each do |k,v| self[k] = v end if _line_or_content.respond_to?(:key)
      @nodes = NodeSet.new(self, _line_or_content) if _line_or_content.respond_to?(:pop) && _col_or_children.nil?
      @column = _col_or_children if _col_or_children.respond_to?(:%)
      @nodes = NodeSet.new(self, _col_or_children) if _col_or_children.respond_to?(:pop)
      @nodes = NodeSet.new(self) if @nodes.empty?
    end

    attr_reader :line, :column

    attr_accessor :nodes
  end

  module ElementGuts
    # @return [Boolean] whether or not this has been written to file
    def abstract?
      line < 0 || column < 0
    end

    # @see Ox::Element#<<
    # this override reports changes to history; NewText for Strings, Add for elements
    #
    # @param obj [Element] element or string to add to this Element
    # @return [Element] self
    def <<(obj)
      case
        when obj.is_a?(Array), obj.is_a?(NodeSet)
          obj.each do |e| self << e end
        when obj.is_a?(String)
          type = :NewText
          super(obj)
        else
          type = :Add
          super(obj)
          if nodes.last.count_observers < 1 && @observer_peers
            nodes.last.add_observer(@observer_peers.first.first)
          end
      end
      report(type, nodes.size - 1)
      self
    end

    # @param attr_sym [String, Symbol] name of attribute
    # @param val [String]
    # @return [Element] self
    def []=(attr_sym, val)
      attr = attr_sym.to_s
      raise "argument to [] must be a Symbol or a String." unless attr.is_a?(Symbol) or attr.is_a?(String)
      args = [attr]
      args << attributes[attr] if attributes[attr]
      super(attr, val)
      type = args.size == 1 ? :NewAttr : :ChangeAttr
      report(type, *args)
      self
    end

    # @return [String] self description
    def description
      "<#{name}>"
    end

    def stub
      Element.new(name, attributes)
    end

    # @return [HistoryClass] history that is observing this element for changes
    def history
      @observer_peers.first.first if @observer_peers.any? and @observer_peers.first.any?
    end

    # @return [String] XML string (overrides Ox's to_s which just prints the object pointer)
    def to_s
      s = %(<#{name})
      attributes.each do |k,v| s << %( #{k.to_s}="#{v}") end
      return s+'/>' if nodes.empty?
      s << ">#{nodes.collect do |n| n.to_s end.join}</#{name}>"
    end

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
    def traverse(&block)
      return self.to_enum unless block_given?
      node_stack = [self]

      until node_stack.empty?
        current = node_stack.shift
        if current
          yield current
          node_stack = node_stack.concat(current.nodes) if current.respond_to?(:nodes)
        end
      end

      self if block_given?
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
  end # class Element < Node
end # module Ox