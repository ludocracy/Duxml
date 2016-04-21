require 'ox'
require File.expand_path(File.dirname(__FILE__) + '/lazy_ox')
require File.expand_path(File.dirname(__FILE__) + '/node_set')

module Duxml
  class Element < ::Ox::Element
    include LazyOx
    include Enumerable
    include Reportable

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

    # @return [Boolean] whether or not this has been written to file
    def abstract?
      line < 0 || column < 0
    end

    # @param obs [Duxml::History] observer to add to this Element as well as its NodeSet
    def add_observer(obs)
      super(obs)
      @nodes.add_observer(obs)
    end

    # @return [Duxml::History] a Duxml::Element extended with History module that is recording this doc's changes
    def history
      @observer_peers.first.first
    end

    # @return [Duxml::Grammar] a Duxml::doc extended with Grammar module that is validating history's changes
    def grammar
      history.grammar
    end

    # now reports to History
    def <<(obj)
      super(obj)
      if nodes.last.is_a?(String)
        type = :NewText
        else
        type = :Add
        nodes.last.add_observer(@observer_peers.first.first) if nodes.last.count_observers < 1 && @observer_peers
      end
      report(type, nodes.last) unless name_space == 'duxml'
      self
    end

    # @param attr [String, Symbol] name of attribute
    # @param val [String]
    # @return [Element] self
    def []=(attr, val)
      raise "argument to [] must be a Symbol or a String." unless attr.is_a?(Symbol) or attr.is_a?(String)
      args = [attr]
      args << attributes[attr] if attributes[attr]
      super(attr, val)
      type = args.size == 1 ? :NewAttribute : :ChangeAttribute
      report(type, *args)
      self
    end

    # now reports to History
    def delete(obj)
      report(:Remove, @nodes.delete(obj))
      obj
    end

    # traverse through this node and all of its descendants; pre-order
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
    def each(&block)
      @nodes.each(&block)
    end

    def name_space
      return nil unless (i = name.index(':'))
      name[0..i-1]
    end

    private
    def report(*args)
      new_args = [args.first, self]
      new_args << args[1..-1] if args.size > 1
      super(*new_args)
    end
  end # class Element < Node
end # module Ox