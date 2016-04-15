require File.expand_path(File.dirname(__FILE__) + '/../../../lib/duxml')
require 'minitest/autorun'

class ValueRuleTest < MiniTest::Test
  include Duxml

  def setup
    load File.expand_path(File.dirname(__FILE__) + '/../../../xml/design.xml')
    @rule = Duxml::ValueRule.new 'foo', 'statement | of | rule'
    @current_meta.grammar << rule
  end

  attr_reader :rule

  def test_init_value_rule
    assert_equal 'value_rule', rule.type
    assert_equal 'foo', rule.attr_name
    assert_equal 'statement|of|rule', rule.statement
    assert_equal nil, rule.object
  end

  def test_applies_to
    target_id = current_design.find_child('legal_parent').id
    assert_equal true, rule.applies_to?(Duxml::AttrValPattern.new %(<attr_val_pattern subject="#{target_id}" attr_name="foo"/>))
    assert_equal true, rule.applies_to?(Duxml::NewAttribute.new %(<new_attribute subject="#{target_id}" attr_name="foo" value="val"/>))
    assert_equal true, rule.applies_to?(Duxml::ChangeAttribute.new %(<change_attribute subject="#{target_id}" attr_name="foo" old_value="old" new_value="new"/>))
    assert_equal false, rule.applies_to?(Duxml::AttrNamePattern.new %(<attr_name_pattern subject="#{target_id}" attr_name="foo"/>))
    assert_equal false, rule.applies_to?(Duxml::AttrValPattern.new %(<attr_name_pattern subject="#{target_id}" attr_name="foofoo"/>))
  end

  def tear_down
  end
end
