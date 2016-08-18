# Copyright (c) 2016 Freescale Semiconductor Inc.

require File.expand_path(File.dirname(__FILE__) + '/../ruby_ext/string')


module Duxml
  module LazyOx
  # welcome to Lazy-Ox - where any method that doesn't exist, you can create on the fly and assign its methods to
  # a corresponding Duxml::Element. see Regexp.nmtoken and String#nmtokenize and String#constantize to see how a given symbol
  # can be converted into XML element names and vice versa. it can also use Class names as method calls to return children by type
  #
  # this method uses Ox::Element's :method_missing but adds an additional rescue block that:
  #   matches namespaced Ruby module to this Element's name and extends this node with module's methods
  #   then method matching symbol is called again with given arguments, yielding result to block if given, returning result if not
  #   e.g.
  #     module Duxml
  #       module Throwable
  #         def throw
  #           puts 'throwing!!'
  #         end
  #       end
  #     end
  #
  #     Element.new('throwable').throw => 'throwing!!'
  #
  #   if symbol name matches a class then method yields to block or returns as array child nodes that matches class
  #   you can further refine search results by adding the symbol of the child instance variable, including name, by which to filter
  #   if block given, returns first child for which block evaluates to true
  #
  #   e.g.
#       class Child; end
  #
  #     n = Element.new('node')
  #     n << 'text'
  #     n << Element.new('child')
  #     n << Element.new('child')
  #     n.Element                                                      # returns Array of Element nodes
  #         => [#<Duxml::Element:0x0002 @value="child" ...>,
  #             #<Duxml::Element:0x0003 @value="child" ...>]
  #
  #     n.Element.each do |child| child << 'some text' end              # adding some text
  #         => ['text',
  #             #<Duxml::Element:0x0002 @value="child" ... @nodes=['some text']>,
  #             #<Duxml::Element 0x0003 @value="child" ... @nodes=['some text']>]
  #
  #     n.Element do |child| child.nodes.first == 'some text' end                             # returns all children for which block is true
  #         => [#<Duxml::Element:0x0002 @value="child" ... @nodes=['some text']>]
  #
  #     %w(bar mar).each_with_index do |x, i| next if i.zero?; n.Child[:foo] = x end        # adding some attributes
  #         => ['text',
  #             #<Duxml::Element:0x0002 @value="child" @attributes={foo: 'bar'} ...>,
  #             #<Duxml::Element:0x0003 @value="child" @attributes={foo: 'mar'} ...>]
  #
  #     n.Element(:foo)                                                                       # returns array of Child nodes with attribute :foo
  #         => [#<Duxml::Element:0x0002 @value="child" @attributes={foo: 'bar'} ...>,
  #             #<Duxml::Element:0x0003 @value="child" @attributes={foo: 'mar'} ...>]
  #
  #     n.Element(foo: 'bar')                                                                 # returns array of Child nodes with attribute :foo equal to 'bar'
  #         => [#<Duxml::Element:0xfff @value="child" @attributes={foo: 'bar'} ...>]
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
  #
  # @param sym [Symbol] method, class or module
  # @param *args [*several_variants] either arguments to method or initializing values for instance of given class
  # @param &block [block] if yielding result, yields to given block; if defining new method, block defines its contents
    def method_missing(sym, *args, &block)
      super(sym, *args, &block)
    rescue NoMethodError, NameError => orig_error
      # handling Constant look up to dynamically extend or add to element
      if lowercase?(sym)
        if (const = look_up_const) and const.is_a?(Module)
          extend const
          result = method(sym).call(*args)
          return(result) unless block_given?
          yield(result)
        elsif block_given?
          new_method = proc(&block)
          self.const_set(sym, new_method)
          return new_method.call *args
        else
          raise orig_error
        end # if (const = look_up_const) ... elsif block_given? ... else ...
      else
        results = filter(sym, args)
        return results unless block_given?
        results.keep_if do |node| yield(node) end
      end # if lowercase? ... else ...
    rescue NoMethodError, NameError
      raise orig_error
    end # def method_missing(sym, *args, &block)

    private

    # @param sym [Symbol] indicates which element type is being filtered for
    # @param args [several_variants] arguments for filtering element children that matched 'sym'
    # @return [[Element]] Elements of type 'sym' that match criteria 'args'
    def filter(sym, args)
      class_nodes = nodes.select do |node|
        node.name == sym.to_s.nmtokenize or simple_class(node) == sym.to_s
      end
      class_nodes.keep_if do |node|
        if args.empty?
          true
        else
          args.any? do |arg|
            if arg.is_a?(Hash)
              node[arg.first.first] == arg.first.last
            else
              !node[arg].nil?
            end
          end
        end # if args.empty? ... else ...
      end # class_nodes.keep_if do |node|
    end # def filter(args)

    # @param maudule [Module] module context in which to look for duck-called method's module
    # @return [Module, Class] requested module or class
    def look_up_const(maudule = Duxml)
      mod_names = name.split(':')
      until mod_names.empty?
        word = mod_names.shift
        k = word.constantize
        if maudule.const_defined?(k, true) or Module.const_defined?(simple_class, true)
          const = maudule.const_get(k)
          if const.is_a?(Module)
            maudule = const
          end

          return const if mod_names.empty? and [Module, Class].include?(const.class)
        end
      end
      nil
    end

    # @param sym [Symbol] symbol for a constant
    # @return [Boolean] is symbol lowercase?
    def lowercase?(sym)
      sym.to_s[0].match(/[A-Z]/).nil?
    end

    # @param obj [Object] usually Element
    # @return [String] name of final Class or Module of self
    def simple_class(obj=self)
      obj.class.to_s.split('::').last
    end
  end # module LazyOx
end # module Duxml