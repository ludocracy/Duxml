require File.expand_path(File.dirname(__FILE__) + '/../lib/duxml')
require 'test/unit'

class DuxmlTest < Test::Unit::TestCase
  include Duxml

  # Called before every test method runs. Can be used
  # to set up fixture information.
  def setup
    @g_path = File.expand_path(File.dirname(__FILE__) + '/../xml/test_grammar.xml')
    @g = Ox.parse_obj File.read g_path
    @d_path = File.expand_path(File.dirname(__FILE__) + '/../xml/design.xml')
  end

  attr_reader :g_path, :d_path, :g

  def test_dita_option
    load(Doc.new, :dita)
    assert_equal GrammarClass, meta.grammar.class
    assert_equal 373, meta.grammar.nodes.size
  end

  def test_load_new
    load Doc.new
    assert_equal GrammarClass, meta.grammar.class
    assert_equal 0, meta.grammar.nodes.size
    assert_equal HistoryClass, meta.history.class
    assert_equal 0, meta.history.nodes.size
  end

  def test_load_with_grammar
    load(d_path, g_path)
    assert_equal 'design', doc.root.name
    assert_equal 'topic', meta.grammar[0].subject
    assert_equal meta.grammar, meta.history.grammar
    assert_equal meta.history, meta.grammar.history
  end

  def test_load_no_file
    assert_raise Exception, "File dne.xml does not exist" do load('dne.xml') end
  end

  def test_illegal_text
    load(d_path)
    text = doc.root.illegal_content.text
    assert_equal '&& <', text
  end

  def test_load_no_grammar
    load(d_path)
    assert_equal false, meta.grammar.defined?
    meta.grammar = g_path
    assert_equal true, meta.grammar.defined?
    assert_equal meta.grammar, meta.history.grammar
    assert_equal meta.history, meta.grammar.history
  end

  def test_load_relative_path
    #TODO test if erroneous paths throw appropriate messages! should then rescue to resume running!
    load('../xml/design.xml')
    assert_equal 'design', doc.root.name
  end

  def test_elements_update_history
    load(d_path)
    doc.root << Element.new('test_node')
    assert_equal 'add_class', meta.history.latest.simple_name
    assert_equal 'design', meta.history.latest.parent.name
    assert_equal 'test_node', meta.history.latest.child.name
  end

  def test_gram_hist_mutual_update
    load(Doc.new, g_path)
    assert_equal meta.grammar, meta.history.grammar
    assert_equal meta.history, meta.grammar.history
    doc << Element.new('topic')
    assert_raise(Exception, '') do doc.topic << Element.new('bogus') end
    meta.history.strict?(false)
    doc.topic << Element.new('bogus')
    assert_equal QualifyErrorClass, meta.history.latest.class
    assert_equal 'bogus', meta.history.latest.bad_change.child.name
    assert_equal meta.history[1].child, meta.history.latest.bad_change.child
  end

  def test_validate
    x = File.expand_path(File.dirname(__FILE__) + '/../xml/dtd_rule_test/error_invalid_attr.xml')
    result = validate(x, g_path)
    assert_equal false, result
    error = meta.history.latest
    assert_equal ValidateErrorClass, error.class
    assert_equal 5, error.line
    assert_equal 'invalid_attr', error.bad_pattern.attr_name
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