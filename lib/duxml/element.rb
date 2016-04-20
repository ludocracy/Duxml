require 'ox'
require File.expand_path(File.dirname(__FILE__) + '/element/node_set')
require File.expand_path(File.dirname(__FILE__) + '/ruby_ext/string')

module Duxml
  class Element < ::Ox::Element
    include Enumerable
    include Reportable

    # gives this element its line and column location then freezes each Fixnum so it cannot be overwritten
    #
    # @param name [String] name of element
    # @param _line [Fixnum] line number in XML document; -1 if not applicable
    # @param _column [Fixnum] column position in XML document; -1 if not applicable
    def initialize(name, _line=-1, _column=-1)
      super name
      @nodes = NodeSet.new(self)
      @line, @column = _line, _column
    end

    attr_reader :line, :column

    attr_accessor :nodes

    def add_observer(obs)
      super(obs)
      @nodes.add_observer(obs)
    end

    def method_missing(sym, *args, &block)
      super(sym, *args, &block)
    rescue NoMethodError
      k = name.split(':').collect do |word| word.constantize end.join('::')
      case
        when Duxml.const_defined?(k)
          const = Duxml.const_get(k)
          case const
            when Module
              extend const
              yield method(sym).call(*args)
            when Class
              yield const.new(*args)
            else
              raise NoMethodError
          end
        when block_given?
          klass = Class.new(Element, &block)
          Duxml.const_set(k, klass)
          new_node = klass.new(*args)
          @nodes << new_node
          yield new_node
        else
          raise NoMethodError
      end
    end # def method_missing(sym, *args, &block)

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