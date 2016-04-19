require File.expand_path(File.dirname(__FILE__) + '/node_set')
require File.expand_path(File.dirname(__FILE__) + '/ox')


module Ox
  class Element < Node
    include Ox
    include Enumerable
    include Reportable


    def nodes
      return @nodes if @nodes.is_a?(NodeSet) && @nodes.count_observers > 0
      if !instance_variable_defined?(:@nodes) or @nodes.nil?
        ns = NodeSet.new self
      else
        ns = NodeSet.new(self, @nodes)
      end
      ns.add_observer(@observer_peers.first.first) if count_observers > 0
      @nodes = ns
    end

    # def method_missing(sym, *args, &block); end

    # now reports to History
    # original code credit to authors of Ox gem
    def <<(obj)
      raise "argument to << must be a String or Ox::Node." unless obj.is_a?(String) or obj.is_a?(Node)
      @nodes = [] if !instance_variable_defined?(:@nodes) or @nodes.nil?
      @nodes << xml(obj)
      type = nodes.last.is_a?(String) ? :NewText : :Add
      report(type, nodes.last)
      self
    end

    # original code credit to authors of Ox gem
    #
    # @param attr [String, Symbol] name of attribute
    # @param val [String]
    # @return [Element] self
    def []=(attr, val)
      raise "argument to [] must be a Symbol or a String." unless attr.is_a?(Symbol) or attr.is_a?(String)

      args = [attr]
      args << attributes[attr] if attributes[attr]
      @attributes = { } if !instance_variable_defined?(:@attributes) or @attributes.nil?
      @attributes[attr] = val.to_s
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

    private
    def report(*args)
      new_args = [args.first, self]
      new_args << args[1..-1] if args.size > 1
      super(*new_args)
    end
  end # class Element < Node
end # module Ox