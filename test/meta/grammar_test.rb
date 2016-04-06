require File.expand_path(File.dirname(__FILE__) + '/../../lib/dux')
require 'minitest/autorun'

class GrammarTest < MiniTest::Test
  include Dux

  def setup
    @child_rule = Dux::ChildrenRule.new 'legal_parent', %((<legal_child> | <also_legal_child>)+)
    @value_rule = Dux::ValueRule.new 'legal_parent', 'test_attr', 'NMTOKEN'
    @attributes_rule = Dux::AttributesRule.new 'legal_parent', 'missing_attr', '#REQUIRED'
    sample_dux = File.expand_path(File.dirname(__FILE__) + '/../../xml/design.xml')
    load sample_dux
  end
  attr_reader :child_rule, :value_rule, :attributes_rule

  def test_xlsx_grammar
    grammar_file = File.expand_path(File.dirname(__FILE__) + '/../../xml/Dita 1.3 Manual Spec Conversion.xlsx')
    sample_dux = File.expand_path(File.dirname(__FILE__) + '/../../xml/dita_test.xml')
    load sample_dux
    current_meta.grammar = grammar_file

    validate
    log 'log.txt'
    assert_equal 7, current_meta.history.size
    assert_equal 'error_no_children', current_meta.history[5].affected_parent.id
    assert_equal 'error_child_in_wrong_pos', current_meta.history[4].affected_parent.id
    assert_equal 'error_many_children_in_wrong_pos', current_meta.history[3].affected_parent.id
    assert_equal 'error_children_split_in_wrong_pos', current_meta.history[1].affected_parent.id
    assert_equal 'error_no_valid_first_child', current_meta.history[0].affected_parent.id
  end

  def test_init_pattern
    target = current_meta.design.find_child %w(legal_parent legal_child)
    p = Dux::ChildPattern.new target.parent, target
    assert_equal 'child_pattern', p.type
    assert_equal 'lp_0', p.subject(current_meta).id
    assert_equal 'lc_0', p.object(current_meta).id
    # test <=>
  end

  def test_grammar_qualify
    sample_dux = File.expand_path(File.dirname(__FILE__) + '/../../xml/design.xml')
    load sample_dux
    current_meta.grammar << [child_rule, value_rule]
    target = current_meta.design.find_child(:legal_parent)
    target << Dux::Object.new(element 'legal_child')
    target << Dux::Object.new(element 'nothing')
    target[:test_attr] = 'fsd ff'
    assert_equal 'qualify_error', current_meta.history.first.type
    assert_equal 'nothing', current_meta.history[2].non_compliant_change.object.type
    assert_equal 'value_rule', current_meta.history.first.violated_rule.type
  end

  def test_grammar_validate_node
    sample_dux = File.expand_path(File.dirname(__FILE__) + '/../../xml/design.xml')
    load sample_dux
    current_meta.grammar << child_rule
    current_meta.grammar << attributes_rule
    target = current_meta.design.find_child(:legal_parent)
    current_meta.grammar.validate target
    assert_equal 'validate_error', current_meta.history.first.type
    assert_equal 'illegal_child', current_meta.history[1].non_compliant_change.object.type
    assert_equal 'attributes_rule', current_meta.history.first.violated_rule.type
  end

  def tear_down
  end
end
