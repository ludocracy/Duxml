require File.expand_path(File.dirname(__FILE__) + '/grammar/pattern/child_pattern')
require File.expand_path(File.dirname(__FILE__) + '/grammar/pattern/text_pattern')
require File.expand_path(File.dirname(__FILE__) + '/grammar/pattern/attr_name_pattern')
require File.expand_path(File.dirname(__FILE__) + '/grammar/pattern/attr_val_pattern')

# methods to create Duxml::Pattern objects from a given Duxml::Object's relationships with its constituents
module PatternMaker
  # @param node [Duxml::Object] object whose relationships are to be made into patterns
  # @return [Array[Duxml::Pattern]] array of patterns representing every relationship of this XMl node and its constituents
  def get_relationships(node)
    [get_child_patterns(node),
     get_null_child_patterns(node),
    get_null_attr_patterns(node),
    get_existing_attr_patterns(node)].flatten
  end

  # @param node [Duxml::Object] object whose relationships are to be made into patterns
  # @return [Array[Duxml::AttrNamePattern, Duxml::AttrValPattern]] one pattern for each existing attribute
  def get_existing_attr_patterns(node)
    # check existing attributes
    node.attributes.collect do |k, v|
      [Duxml::AttrNamePattern.new(node, k), Duxml::AttrValPattern.new(node, k)]
    end.flatten
  end

  # @param node [Duxml::Object] object whose relationships are to be made into patterns
  # @return [Array[Duxml::AttrNamePattern]] one pattern for each attribute that should but does not exist
  def get_null_attr_patterns(node)
    find_children(:attributes_rule).collect do |attr_rule|
      if attr_rule.required? && node.simple_class == attr_rule.subject
        Duxml::AttrNamePattern.new(node, attr_rule.attr_name) unless node[attr_rule.attr_name]
      end
    end.compact
  end

  # @param node [Duxml::Object] object whose relationships are to be made into patterns
  # @return [Array[Duxml::ChildPattern]]
  def get_null_child_patterns(node)
    find_children(:children_rule).each do |child_rule|
      if node.simple_class == child_rule.subject
        return child_rule.required_children.collect do |required_child_type|
          Duxml::ChildPattern.new(node, required_child_type) unless node.find_child required_child_type
        end.compact
      end
    end
    []
  end

  # @param node [Duxml::Object] object whose relationships are to be made into patterns
  # @return [Array[Duxml::ChildPattern, Duxml::ContentPattern]] one pattern for each child
  def get_child_patterns(node)
    if node.children.any? do |child| !child.text? end
      node.children.collect do |child|
        Duxml::ChildPattern.new(node, child)
      end
    elsif node.children.any?
      [Duxml::ContentPattern.new(node, node.content)]
    else
      [Duxml::ChildPattern.new(node)]
    end
  end # def get_child_patterns
end # module PatternMaker
