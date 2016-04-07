require 'tree'

# rubytree gem bug fix; submit to project once you can replicate in test!
# previous algorithm was:
# node_stack = current.children.concat(node_stack)
# because @children mutated, had side effect of orphaning children occasionally
# new algorithm is:
# node_stack = node_stack.concat(current.children)
module Tree
  class TreeNode
    def each(&block)             # :yields: node

      return self.to_enum unless block_given?

      node_stack = [self]   # Start with this node

      until node_stack.empty?
        current = node_stack.shift    # Pop the top-most node
        if current                    # Might be 'nil' (esp. for binary trees)
          yield current               # and process it
          node_stack = node_stack.concat(current.children)
        end
      end

      return self if block_given?
    end
  end
end