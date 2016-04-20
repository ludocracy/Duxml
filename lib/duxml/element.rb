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

    # @return [Boolean] whether or not this has been written to file
    def abstract?
      line < 0 || column < 0
    end

    # @param obs [Duxml::History] observer to add to this Element as well as its NodeSet
    def add_observer(obs)
      super(obs)
      @nodes.add_observer(obs)
    end

    # @return [Duxml::History] a Duxml::Element extended with History module that is recording this element's changes
    def history
      @observer_peers.first.first
    end

    # @return [Duxml::Grammar] a Duxml::element extended with Grammar module that is validating history's changes
    def grammar
      history.grammar
    end

    # welcome to Lazy-Ox - where any method or class that doesn't exist, you can create on the fly and assign its methods to
    # a corresponding Duxml::Element. see Regexp.nmtoken and String#nmtokenize and String#constantize to see how a given symbol
    # can be converted into XML element names and vice versa.
    #
    # this method uses Ox::Element's :method_missing but adds an additional rescue block that:
    #   matches namespaced Ruby module to this Element's name and extends this node with module's methods
    #   then method is called again with given arguments, yielding result to block if given, returning result if not
    #   e.g.
    #     module Duxml
    #       module Throwable
    #         def throw
    #           puts 'throwing!!'
    #         end
    #       end
    #     end
    #
    #     Element.new('duxml:throwable').throw => 'throwing!!'
    #
    #   if element name matches a class then method returns or yields a new object of that class, initialized with *args
    #   e.g.
    #     module Duxml
    #       class Rug
    #         def initialize(_color)
    #           @color = _color
    #         end
    #         attr_reader :color
    #       end
    #     end
    #
    #     n = Element.new('node')
    #     n.Rug('chartreuse').color => 'chartreuse'
    #
    #
    #   if element name has no matching Class or Module in namespace,
    #     if symbol is lower case, it is made into a method, given &block as definition, then called with *args
    #       e.g. n.change_color('blue') do |new_color|  => #<Duxml::Element:0xfff @value="node" @attributes={color: 'blue'} @nodes=[]>
    #              @color = new_color
    #              self
    #            end
    #            n.color                                => 'blue'
    #            n.change_color('mauve').color          => 'mauve'
    #     if symbol is upper case, symbol is made into new class subclassing Duxml::Element and taking given block
    #     as its definition. an instance of the new class is initialized with *args and after adding it to this node's children, returned
    #       e.g. n.Ottoman('green') do
    #         def initialize(_color); @color = _color end
    #       end
    #       attr_reader: color
    #     end                                           => #<Duxml::Element:0xfff @value="ottoman" @attributes={color: 'green'} @nodes=[]>
    #     n.ottoman.color                               => 'green'
    #
    # @param sym [Symbol] method, class or module
    # @param *args [*several_variants] either arguments to method or initializing values for instance of given class
    # @param &block [block] if yielding result, yields to given block; if defining new constant or method, block defines its contents
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
              result = method(sym).call(*args)
            when Class
              result = const.new(*args)
              @nodes << result
            else
              raise NoMethodError
          end
          if block_given?
              yield(result)
            else
              return(result)
          end
        when block_given?
          if sym.to_s[0].match(/[A-Z]/)
            klass = Class.new(Element, &block)
            Duxml.const_set(k, klass)
            new_node = klass.new(*args)
            @nodes << new_node
            return new_node
          else
            new_method = proc(&block)
            Duxml.const_set(sym, new_method)
            return new_method.call *args
          end
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