require File.expand_path(File.dirname(__FILE__) + '/pattern/child_pattern')
require File.expand_path(File.dirname(__FILE__) + '/pattern/text_pattern')
require File.expand_path(File.dirname(__FILE__) + '/pattern/attr_name_pattern')
require File.expand_path(File.dirname(__FILE__) + '/pattern/attr_val_pattern')

module Duxml
  # methods to create Patterns from a given Element's relationships with its members
  module PatternMaker
    include Duxml
    # @param node [Duxml::Element] doc whose relationships are to be made into patterns
    # @return [Array[Duxml::Pattern]] array of patterns representing every relationship of this XMl node and its members
    def get_relationships(node)
      [get_child_patterns(node),
       get_null_child_patterns(node),
      get_null_attr_patterns(node),
      get_existing_attr_patterns(node)].flatten
    end

    # @param node [Duxml::Element] doc whose relationships are to be made into patterns
    # @return [Array[Duxml::AttrNamePattern, Duxml::AttrValPattern]] one pattern for each existing attribute
    def get_existing_attr_patterns(node)
      # check existing attributes
      node.attributes.collect do |k, v|
        [AttrNamePattern.new(node, k), AttrValPattern.new(node, k)]
      end.flatten
    end

    # @param node [Element] doc whose relationships are to be made into patterns
    # @return [Array[AttrNamePattern]] one pattern for each attribute that should but does not exist
    def get_null_attr_patterns(node)
      self.AttributesRule.collect do |attr_rule|
        if attr_rule.required? && node.name == attr_rule.subject
          AttrNamePattern.new(node, attr_rule.attr_name) unless node[attr_rule.attr_name]
        end
      end.compact
    end

    # @param node [Duxml::Element] doc whose relationships are to be made into patterns
    # @return [Array[ChildPattern]] one pattern for each child that should be there but isn't
    def get_null_child_patterns(node)
      self.ChildrenRule.each do |child_rule|
        if node.name == child_rule.subject
          return child_rule.required_children.collect do |required_child_type|
            ChildPattern.new(node, required_child_type) unless node.send(required_child_type.constantize)
          end.compact
        end
      end
      []
    end

    # @param node [Duxml::Element] object whose relationships are to be made into patterns
    # @return [Array[Duxml::ChildPattern, Duxml::ContentPattern]] one pattern for each child that exists
    def get_child_patterns(node)
      node.nodes.collect do |child|
        if child.is_a?(Duxml::Element)
          ChildPattern.new(node, child)
        else
          TextPattern.new(node, child)
        end
      end
    end # def get_child_patterns
  end # module PatternMaker
end # module Duxml