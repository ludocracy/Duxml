require File.expand_path(File.dirname(__FILE__) + '/../ruby_tree_ext/tree')
require File.expand_path(File.dirname(__FILE__) + '/../ruby_ext/object')

module Duxml
  # Duxml class for XML text nodes
  class PCData < Tree::TreeNode
    attr_reader :xml

    # always initialized from a string, either via interface or from XML text
    # note that the actual XML is not changed - this object is only a Ruby abstraction
    # that allows traversing through text nodes in order with XML child nodes
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

    def type
      simple_class
    end

    alias_method :content, :to_s
    alias_method :id, :name

    # change text value
    def content=(new_text)
      return nil if new_text.xml
      @xml = new_text
    end

    # this is a text node
    def text?
      true
    end
  end # class PCData
end # module Duxml