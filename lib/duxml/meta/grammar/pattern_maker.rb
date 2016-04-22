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
       get_existing_attr_patterns(node),
      get_null_attr_patterns(node)].flatten
    end

    # @param node [Duxml::Element] doc whose relationships are to be made into patterns
    # @return [Array[Duxml::AttrNamePattern, Duxml::AttrValPattern]] one pattern for each existing attribute
    def get_existing_attr_patterns(node)
      # check existing attributes
      node.attributes.collect do |k, v|
        [AttrNamePatternClass.new(node, k), AttrValPatternClass.new(node, k)]
      end.flatten
    end

    # @param node [Element] doc whose relationships are to be made into patterns
    # @return [Array[AttrNamePattern]] one pattern for each attribute that should but does not exist
    def get_null_attr_patterns(node)
      self.AttrsRuleClass.collect do |attr_rule|
        if attr_rule.required? && node.name == attr_rule.subject
          AttrNamePatternClass.new(node, attr_rule.attr_name) unless node[attr_rule.attr_name]
        end
      end.compact
    end

    # @param node [Duxml::Element] doc whose relationships are to be made into patterns
    # @return [Array[ChildPattern]] one pattern for each child that should be there but isn't
    def get_null_child_patterns(node)
      self.ChildrenRuleClass.each do |child_rule|
        if node.name == child_rule.subject
          return child_rule.required_children.collect do |required_child_type|
            unless node.nodes.any? do |n| n.name == required_child_type end
              NullChildPatternClass.new(node, required_child_type)
            end
          end.compact
        end
      end
      []
    end

    # @param node [Duxml::Element] object whose relationships are to be made into patterns
    # @return [Array[Duxml::ChildPattern, Duxml::ContentPattern]] one pattern for each child that exists
    def get_child_patterns(node)
      i = -1
      node.nodes.collect do |child|
        i += 1
        if child.is_a?(String)
          TextPatternClass.new(node, i)
        else
          ChildPatternClass.new(node, i)
        end
      end
    end # def get_child_patterns
  end # module PatternMaker
end # module Duxml