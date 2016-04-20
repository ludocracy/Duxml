require File.expand_path(File.dirname(__FILE__) + '/../../../lib/duxml')
require 'minitest/autorun'

class ChildrenRuleTest < MiniTest::Test
  include Duxml

  def setup
    load File.expand_path(File.dirname(__FILE__) + '/../../../xml/design.xml')
    @rule = Duxml::ChildrenRule.new 'legal_parent', '<statement> | of-rule'
    @current_meta.grammar << rule
  end

  attr_reader :rule

  def test_init_child_rule
    assert_equal 'children_rule', rule.type
    assert_equal 'legal_parent', rule.subject
    assert_equal '\\bstatement\\b|\\bof-rule\\b', rule.statement
    assert_equal nil, rule.object
  end

  def test_applies_to
    target_id = current_design.find_child('legal_parent').id
    assert_equal true, rule.applies_to?(Duxml::ChildPattern.new %(<child_pattern subject="#{target_id}"/>))
    assert_equal true, rule.applies_to?(Duxml::Add.new %(<add subject="#{target_id}"/>))
    assert_equal true, rule.applies_to?(Duxml::Remove.new %(<remove subject="#{target_id}"/>))
    assert_equal false, rule.applies_to?(Duxml::ChildPattern.new %(<child_pattern subject="foo"/>))
  end

  def tear_down
  end
end
