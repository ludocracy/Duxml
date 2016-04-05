require File.expand_path(File.dirname(__FILE__) + '/../ruby_tree_ext/tree')
require File.expand_path(File.dirname(__FILE__) + '/../ruby_ext/object')

module Dux
  # Dux class for XML text nodes
  class PCData < Tree::TreeNode
    attr_reader :xml

    # always initialized from a string, either via interface or from XML text
    def initialize(text_node)
      @xml = text_node.to_s
      super new_id
    end

    def description
      content
    end

    # dissolves object into String
    def to_s
      xml
    end

    def content
      xml
    end

    # this is a text node
    def text?
      true
    end
  end # class PCData
end # module Dux