require File.expand_path(File.dirname(__FILE__) + '/../../../lib/duxml/meta/grammar/rule/children_rule')
require 'minitest/autorun'

class ChildrenRuleTest < MiniTest::Test
  def setup
  end

  def test_init_child_rule
    rule = Duxml::ChildrenRule.new 'legal_parent', '<statement> | of-rule'
    rule0 = Duxml::ChildrenRule.new rule.xml
    assert_equal rule.to_s, rule0.to_s
    assert_equal 'children_rule', rule.type
    assert_equal 'legal_parent', rule.subject
    assert_equal '\\bstatement\\b|\\bof-rule\\b', rule.statement
    assert_equal nil, rule.object
  end

  def test_relaxng
    rule = Duxml::ChildrenRule.new 'legal_parent', '(allowed|also_allowed)+'
    test_xml = element 'grammar'
    rng_xml = rule.relaxng test_xml
    assert_equal 'oneOrMore', rng_xml.element_children.first.element_children.first.name
  end

  def tear_down
  end
end
