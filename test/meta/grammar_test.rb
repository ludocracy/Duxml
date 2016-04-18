require File.expand_path(File.dirname(__FILE__) + '/../../lib/duxml')
require 'test/unit'

class GrammarTest < Test::Unit::TestCase
  include Duxml

  def setup
    @child_rule = Duxml::ChildrenRule.new 'legal_parent', %((<legal_child> | <also_legal_child>)+)
    @value_rule = Duxml::ValueRule.new 'test_attr', 'NMTOKEN'
    @attributes_rule = Duxml::AttributesRule.new 'legal_parent', 'missing_attr', '#REQUIRED'
    @test_grammar = Grammar.new File.expand_path(File.dirname(__FILE__) + '/../../xml/test_grammar.xml')
  end
  attr_reader :child_rule, :value_rule, :attributes_rule, :test_grammar

  def test_xlsx_grammar
    xlsx_grammar = File.expand_path(File.dirname(__FILE__) + '/../../xml/Dita 1.3 Manual Spec Conversion.xlsx')
    g = Grammar.new xlsx_grammar
    assert_equal 'topic', g.children.first.subject
    assert_equal 'children_rule', g.children.first.simple_class
    File.write File.expand_path(File.dirname(__FILE__) + '/../../xml/test_grammar.xml'), g.xml.to_xml
  end # def test_xlsx_grammar

  def test_arbitrary_data_and_child
    sample_dux = File.expand_path(File.dirname(__FILE__) + "/../../xml/dtd_rule_test/arbitrary_data_and_child.xml")
    load sample_dux
    current_meta.grammar = test_grammar
    assert_equal true, validate
  end

  def test_data_and_child
    sample_dux = File.expand_path(File.dirname(__FILE__) + "/../../xml/dtd_rule_test/data_and_child.xml")
    load sample_dux
    current_meta.grammar = test_grammar
    assert_equal true, validate
  end

  def test_error_child_in_wrong_pos
    sample_dux = File.expand_path(File.dirname(__FILE__) + "/../../xml/dtd_rule_test/error_child_in_wrong_pos.xml")
    load sample_dux
    current_meta.grammar = test_grammar
    assert_equal false, validate
  end

  def test_error_children_split_in_wrong_pos
    sample_dux = File.expand_path(File.dirname(__FILE__) + "/../../xml/dtd_rule_test/error_children_split_in_wrong_pos.xml")
    load sample_dux
    current_meta.grammar = test_grammar
    assert_equal false, validate
  end

  def test_error_interleaved_invalid_child_text
    sample_dux = File.expand_path(File.dirname(__FILE__) + "/../../xml/dtd_rule_test/error_interleaved_invalid_child_text.xml")
    load sample_dux
    current_meta.grammar = test_grammar
    assert_equal false, validate
  end

  def test_error_invalid_attr
    sample_dux = File.expand_path(File.dirname(__FILE__) + "/../../xml/dtd_rule_test/error_invalid_attr.xml")
    load sample_dux
    current_meta.grammar = test_grammar
    assert_equal false, validate
  end

  def test_error_invalid_attr_val
    sample_dux = File.expand_path(File.dirname(__FILE__) + "/../../xml/dtd_rule_test/error_invalid_attr_val.xml")
    load sample_dux
    current_meta.grammar = test_grammar
    assert_equal false, validate
  end

  def test_error_many_children_in_wrong_pos
    sample_dux = File.expand_path(File.dirname(__FILE__) + "/../../xml/dtd_rule_test/error_many_children_in_wrong_pos.xml")
    load sample_dux
    current_meta.grammar = test_grammar
    assert_equal false, validate
  end

  def test_error_missing_attr
    sample_dux = File.expand_path(File.dirname(__FILE__) + "/../../xml/dtd_rule_test/error_missing_attr.xml")
    load sample_dux
    current_meta.grammar = test_grammar
    assert_equal false, validate
  end

  def test_error_no_children
    sample_dux = File.expand_path(File.dirname(__FILE__) + "/../../xml/dtd_rule_test/error_no_children.xml")
    load sample_dux
    current_meta.grammar = test_grammar
    assert_equal false, validate
  end

  def test_error_no_valid_first_child
    sample_dux = File.expand_path(File.dirname(__FILE__) + "/../../xml/dtd_rule_test/error_no_valid_first_child.xml")
    load sample_dux
    current_meta.grammar = test_grammar
    assert_equal false, validate
  end

  def test_interleaved_valid_children_text
    sample_dux = File.expand_path(File.dirname(__FILE__) + "/../../xml/dtd_rule_test/interleaved_valid_children_text.xml")
    load sample_dux
    current_meta.grammar = test_grammar
    assert_equal true, validate
  end

  def test_plural_children
    sample_dux = File.expand_path(File.dirname(__FILE__) + "/../../xml/dtd_rule_test/plural_children.xml")
    load sample_dux
    current_meta.grammar = test_grammar
    assert_equal true, validate
  end

  def test_single_child
    sample_dux = File.expand_path(File.dirname(__FILE__) + "/../../xml/dtd_rule_test/single_child.xml")
    load sample_dux
    current_meta.grammar = test_grammar
    assert_equal true, validate
  end

  def test_grammar_qualify
    sample_dux = File.expand_path(File.dirname(__FILE__) + '/../../xml/design.xml')
    load sample_dux
    current_meta.grammar << [child_rule, value_rule]
    target = current_meta.design.find_child(:legal_parent)
    target << Duxml::Object.new(element 'legal_child')
    target << Duxml::Object.new(element 'nothing')
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
