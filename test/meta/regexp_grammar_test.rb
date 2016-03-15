require File.expand_path(File.dirname(__FILE__) + '/../../lib/dux')
require File.expand_path(File.dirname(__FILE__) + '/../../lib/dux/meta/grammar/regexp_grammar')
require 'minitest/autorun'

class RegexpGrammarTest < MiniTest::Test
  include Dux

  def setup
    grammar_file = File.expand_path(File.dirname(__FILE__) + '/../../xml/Dita 1.3 Manual Spec Conversion.xlsx')
    sample_dux = File.expand_path(File.dirname(__FILE__) + '/../../xml/dita_test.xml')
    @meta = load sample_dux
    @meta.grammar = grammar_file
  end
  attr_reader :meta

  def test_load_xlsx
    assert_equal "child_rule(object, \"(data|sort-as|data-about)*,li+\")", meta.grammar.first_child.content
  end

  def test_xlsx_grammar
    validate
    assert_equal 'error_no_children', meta.history[0].object.id
    assert_equal 'error_child_in_wrong_pos', meta.history[1].object.id
    assert_equal 'error_many_children_in_wrong_pos', meta.history[2].object.id
    assert_equal 'error_children_split_in_wrong_pos', meta.history[3].object.id
    assert_equal 'error_no_valid_first_child', meta.history[4].object.id
  end

  def tear_down
  end
end
