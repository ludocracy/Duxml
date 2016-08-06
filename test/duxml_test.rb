# Copyright (c) 2016 Freescale Semiconductor Inc.
require File.expand_path(File.dirname(__FILE__) + '/../lib/duxml')
require 'test/unit'

class Dummy
  def answer
    'answer!'
  end
end

class DuxmlTest < Test::Unit::TestCase
  include Duxml

  # Called before every test method runs. Can be used
  # to set up fixture information.
  def setup
    @g_path = File.expand_path(File.dirname(__FILE__) + '/../xml/dita_grammar.xml')
    @g = Ox.parse_obj File.read g_path
    @d_path = File.expand_path(File.dirname(__FILE__) + '/../xml/design.xml')
  end

  attr_reader :g_path, :d_path, :g

  def test_load_new
    load 'test.xml'
    assert_equal GrammarClass, doc.grammar.class
    assert_equal 0, doc.grammar.nodes.size
    assert_equal HistoryClass, doc.history.class
    assert_equal 0, doc.history.nodes.size
  end

  def test_load_with_grammar
    load(d_path, g_path)
    assert_equal 'design', doc.root.name
    assert_equal 'topic', doc.grammar[0].subject
    assert_equal doc.grammar, doc.history.grammar
    assert_equal doc.history, doc.grammar.history
  end

  def test_illegal_text
    load(d_path)
    text = doc.root.illegal_content.text
    assert_equal '&& <', text
  end

  def test_load_no_grammar
    load(d_path)
    assert_equal false, doc.grammar.defined?
    doc.grammar = g_path
    assert_equal true, doc.grammar.defined?
    assert_equal doc.grammar, doc.history.grammar
    assert_equal doc.history, doc.grammar.history
  end

  def test_load_relative_path
    #TODO test if erroneous paths throw appropriate messages! should then rescue to resume running!
    load('../xml/design.xml')
    assert_equal 'design', doc.root.name
  end

  def test_elements_update_history
    load(d_path)
    doc.root << Element.new('test_node')
    assert_equal 'add_class', doc.history.latest.simple_name
    assert_equal 'design', doc.history.latest.parent.name
    assert_equal 'test_node', doc.history.latest.child.name
  end

  def test_gram_hist_mutual_update
    load(Doc.new, g_path)
    assert_equal doc.grammar, doc.history.grammar
    assert_equal doc.history, doc.grammar.history
    doc << Element.new('topic')
    assert_raise(Exception, '') do doc.topic << Element.new('bogus') end
    doc.history.strict?(false)
    doc.topic << Element.new('bogus')
    assert_equal QualifyErrorClass, doc.history.latest.class
    assert_equal 'bogus', doc.history.latest.bad_change.child.name
    assert_equal doc.history[1].child, doc.history.latest.bad_change.child
  end

  def test_validate
    x = File.expand_path(File.dirname(__FILE__) + '/../xml/dtd_rule_test/error_invalid_attr_val.xml')
    result = validate(x, grammar: g_path)
    assert_equal false, result
    error = doc.history.latest
    assert_equal ValidateErrorClass, error.class
    assert_equal 5, error.line
    assert_equal 'invalid_attr', error.bad_pattern.attr_name
    puts doc.history.description
  end

  def test_validate_log
    # test that validate outputs to STDERR or console, etc., given option :output

  end

  def test_save_file
    # save XML file

    # check to see that metadata also saved
  end


  # Called after every test method runs. Can be used to tear
  # down fixture information.

  def teardown
    # Do nothing
  end
end