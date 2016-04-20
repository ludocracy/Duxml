require File.expand_path(File.dirname(__FILE__) + '/../../../lib/duxml')
require 'minitest/autorun'

class ContentRuleTest < MiniTest::Test
  include Duxml

  def setup
    load File.expand_path(File.dirname(__FILE__) + '/../../../xml/design.xml')
    @rule = Duxml::ContentRule.new 'legal_parent', 'statement of rule'
    @current_meta.grammar << rule
  end

  attr_reader :rule

  def test_init_content_rule
    rule = Duxml::ContentRule.new 'legal_parent', 'statement of rule'
    assert_equal 'content_rule', rule.type
    assert_equal 'legal_parent', rule.subject
    assert_equal 'statementofrule', rule.statement
    assert_equal nil, rule.object
    # test <=>
  end

  def test_applies_to
    target_id = current_design.find_child('legal_parent').id
    assert_equal true, rule.applies_to?(Duxml::ContentPattern.new %(<content_pattern subject="#{target_id}"/>))
    assert_equal true, rule.applies_to?(Duxml::NewContent.new %(<new_content subject="#{target_id}"/>))
    assert_equal true, rule.applies_to?(Duxml::ChangeContent.new %(<change_content subject="#{target_id}"/>))
    assert_equal false, rule.applies_to?(Duxml::AttrNamePattern.new %(<attr_name_pattern subject="#{target_id}"/>))
  end

  def tear_down
  end
end
