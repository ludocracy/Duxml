require File.expand_path(File.dirname(__FILE__) + '/../../lib/dux')
require 'minitest/autorun'

class GrammarTest < MiniTest::Test
  include Dux

  def setup
    @child_rule = Dux::ChildRule.new 'legal_parent', %((<legal_child> | <also_legal_child>)+)
    sample_dux = File.expand_path(File.dirname(__FILE__) + '/../../xml/design.xml')
    @meta = load sample_dux
  end
  attr_reader :meta, :child_rule

  def test_xlsx_grammar
    grammar_file = File.expand_path(File.dirname(__FILE__) + '/../../xml/Dita 1.3 Manual Spec Conversion.xlsx')
    sample_dux = File.expand_path(File.dirname(__FILE__) + '/../../xml/dita_test.xml')
    ditameta = load sample_dux
    ditameta.grammar = grammar_file

    validate
    log 'log.txt'
    assert_equal 7, ditameta.history.size
    assert_equal 'error_no_children', ditameta.history[5].affected_parent.id
    assert_equal 'error_child_in_wrong_pos', ditameta.history[4].affected_parent.id
    assert_equal 'error_many_children_in_wrong_pos', ditameta.history[3].affected_parent.id
    assert_equal 'error_children_split_in_wrong_pos', ditameta.history[1].affected_parent.id
    assert_equal 'error_no_valid_first_child', ditameta.history[0].affected_parent.id
  end

  def test_init_pattern
    target = meta.design.find_child %w(legal_parent legal_child)
    p = Dux::ChildPattern.new target.parent, target
    assert_equal 'child_pattern', p.type
    assert_equal 'lp_0', p.subject(meta).id
    assert_equal 'lc_0', p.object(meta).id
    # test <=>
  end

  def test_grammar_qualify
    sample_dux = File.expand_path(File.dirname(__FILE__) + '/../../xml/design.xml')
    meta = load sample_dux
    meta.grammar << child_rule
    target = meta.design.find_child(:legal_parent)
    target << Dux::Object.new(element 'legal_child')
    target << Dux::Object.new(element 'nothing')
    assert_equal 'qualify_error', meta.history.first.type
    assert_equal 'nothing', meta.history.first.non_compliant_change.object.type
  end

  def test_grammar_validate_node
    sample_dux = File.expand_path(File.dirname(__FILE__) + '/../../xml/design.xml')
    meta = load sample_dux
    meta.grammar << child_rule
    target = meta.design.find_child(:legal_parent)
    meta.grammar.validate target
    assert_equal 'validate_error', meta.history.first.type
    assert_equal 'illegal_child', meta.history.first.non_compliant_change.object.type
  end

  def tear_down
  end
end
