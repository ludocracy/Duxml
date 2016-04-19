require File.expand_path(File.dirname(__FILE__) + '/../../../lib/duxml')
require 'minitest/autorun'

class AttributesRuleTest < MiniTest::Test
  include Duxml

  def setup
    load File.expand_path(File.dirname(__FILE__) + '/../../../xml/design.xml')
    @rule = Duxml::AttributesRule.new 'legal_parent', 'foo', 'requirement'
    @current_meta.grammar << rule
  end

  attr_reader :rule

  def test_init_attributes_rule
    assert_equal 'attributes_rule', rule.type
    assert_equal 'legal_parent', rule.subject
    assert_equal 'foo', rule.attr_name
    assert_equal '\\bfoo\\b', rule.statement
    assert_equal 'requirement', rule[:requirement]
    assert_equal nil, rule.object
  end

  def test_applies_to
    target_id = current_design.find_child('legal_parent').id
    assert_equal true, rule.applies_to?(Duxml::AttrNamePattern.new %(<attr_name_pattern subject="#{target_id}" attr_name="foo"/>))
    assert_equal true, rule.applies_to?(Duxml::NewAttribute.new %(<new_attribute subject="#{target_id}" attr_name="foo"/>))
    assert_equal false, rule.applies_to?(Duxml::AttrNamePattern.new %(<attr_name_pattern subject="#{target_id}" attr_name="foofoo"/>))

  end

  def tear_down
  end
end
