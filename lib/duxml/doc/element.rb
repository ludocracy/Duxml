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

    # gives this doc its line and column location then freezes each Fixnum so it cannot be overwritten
    #
    # @param name [String] name of doc
    # @param _line [Fixnum] line number in XML document; -1 if not applicable
    # @param _column [Fixnum] column position in XML document; -1 if not applicable
    def initialize(name, _line=-1, _column=-1)
      super name
      @nodes = NodeSet.new(self)
      @line, @column = _line, _column
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

    # TODO do we need this method to take Fixnum node index as well?
    # @param obj [Element] element child to delete
    # @return [Element] deleted element
    def delete(obj)
      report(:Remove, @nodes.delete(obj))
      obj
    end

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