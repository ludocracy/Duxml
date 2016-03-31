require File.expand_path(File.dirname(__FILE__) + '/../../../lib/dux/meta/grammar/rule/content_rule')
require 'minitest/autorun'

class ContentRuleTest < MiniTest::Test
  def setup
  end

  def test_init_content_rule
    rule = Dux::ContentRule.new subject: 'legal_parent', statement: '<statement> of rule'
    assert_equal 'content_rule', rule.type
    assert_equal 'legal_parent', rule.subject
    assert_equal '\\bstatement\\bofrule', rule.statement
    assert_equal nil, rule.object
    # test <=>
  end

  def tear_down
  end
end