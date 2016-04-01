require File.expand_path(File.dirname(__FILE__) + '/../../../lib/dux/meta/grammar/rule/attr_name_rule')
require 'minitest/autorun'

class AttrNameRuleTest < MiniTest::Test
  def setup
  end

  def test_init_attr_name_rule
    rule = Dux::ChildRule.new subject: 'legal_parent', statement: '<statement> of rule'
    assert_equal 'child_rule', rule.type
    assert_equal 'legal_parent', rule.subject
    assert_equal '<statement> of rule', rule.statement
    assert_equal nil, rule.object
  end

  def tear_down
  end
end
