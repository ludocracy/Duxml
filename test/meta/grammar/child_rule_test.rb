require File.expand_path(File.dirname(__FILE__) + '/../../../lib/dux/meta/grammar/rule/child_rule')
require 'minitest/autorun'

class ChildRuleTest < MiniTest::Test
  def setup
  end

  def test_init_child_rule
    rule = Dux::ChildRule.new subject: 'legal_parent', statement: '<statement> of rule'
    rule0 = Dux::ChildRule.new rule.xml
    assert_equal rule.to_s, rule0.to_s
    assert_equal 'child_rule', rule.type
    assert_equal 'legal_parent', rule.subject
    assert_equal '<statement> of rule', rule.statement
    assert_equal nil, rule.object
  end

  def tear_down
  end
end
