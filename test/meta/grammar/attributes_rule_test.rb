require File.expand_path(File.dirname(__FILE__) + '/../../../lib/duxml/meta/grammar/rule/attributes_rule')
require 'minitest/autorun'

class AttributesRuleTest < MiniTest::Test
  def setup
  end

  def test_init_attributes_rule
    rule = Duxml::AttributesRule.new 'legal_parent', 'statement | of | rule', 'requirement'
    assert_equal 'attributes_rule', rule.type
    assert_equal 'legal_parent', rule.subject
    assert_equal '\\bstatement\\b|\\bof\\b|\\brule\\b', rule.statement
    assert_equal 'requirement', rule[:requirement]
    assert_equal nil, rule.object
  end

  def tear_down
  end
end
