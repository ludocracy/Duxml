require File.expand_path(File.dirname(__FILE__) + '/../../../lib/dux/meta/grammar/rule/children_rule')
require 'minitest/autorun'

class ChildrenRuleTest < MiniTest::Test
  def setup
  end

  def test_init_child_rule
    rule = Dux::ChildrenRule.new 'legal_parent', '<statement> | of-rule'
    rule0 = Dux::ChildrenRule.new rule.xml
    assert_equal rule.to_s, rule0.to_s
    assert_equal 'children_rule', rule.type
    assert_equal 'legal_parent', rule.subject
    assert_equal '\\bstatement\\b|\\bof-rule\\b', rule.statement
    assert_equal nil, rule.object
  end

  def tear_down
  end
end
