require File.expand_path(File.dirname(__FILE__) + '/../../../lib/duxml/meta/grammar')
require File.expand_path(File.dirname(__FILE__) + '/../../../lib/duxml/saxer')
require 'test/unit'

class Observer
  def update(*args)
    @args = args
  end

  attr_reader :args
end

class GrammarTest < Test::Unit::TestCase
  include Duxml
  include Saxer

  def setup
    @g = Ox.parse_obj File.read File.expand_path(File.dirname(__FILE__) + '/../../../xml/test_grammar.xml')
    @o = Observer.new
    g.add_observer o
  end

  attr_reader :g, :o

  def test_xml
    Grammar.xml.name
  end

  def test_data_and_child
    doc = sax File.expand_path(File.dirname(__FILE__) + "/../../../xml/dtd_rule_test/data_and_child.xml")
    ol = doc.topic.body.ol
    result = g.validate ol
    assert_equal true, result
  end

  def test_arbitrary_data_and_child
    doc = sax File.expand_path(File.dirname(__FILE__) + "/../../../xml/dtd_rule_test/arbitrary_data_and_child.xml")
    ol = doc.topic.body.ol
    result = g.validate ol
    assert_equal true, result
  end

  def test_error_child_in_wrong_pos
    doc = sax File.expand_path(File.dirname(__FILE__) + "/../../../xml/dtd_rule_test/error_child_in_wrong_pos.xml")
    ol = doc.topic.body.ol
    result = g.validate ol
    assert_equal false, result
    assert_equal :ValidateError, o.args[0]
    assert_equal 'children_rule_class', o.args[1].simple_name
    assert_equal 1, o.args[2].index
  end

  def test_error_children_split_in_wrong_pos
    doc = sax File.expand_path(File.dirname(__FILE__) + "/../../../xml/dtd_rule_test/error_children_split_in_wrong_pos.xml")
    ol = doc.topic.body.ol
    result = g.validate ol
    assert_equal false, result
    assert_equal :ValidateError, o.args[0]
    assert_equal 'children_rule_class', o.args[1].simple_name
    assert_equal 1, o.args[2].index
  end

  def test_error_interleaved_invalid_child_text
    doc = sax File.expand_path(File.dirname(__FILE__) + "/../../../xml/dtd_rule_test/error_interleaved_invalid_child_text.xml")
    p = doc.topic.body.p
    result = g.validate p
    assert_equal false, result
    assert_equal :ValidateError, o.args[0]
    assert_equal 'children_rule_class', o.args[1].simple_name
    assert_equal 'invalid_child', o.args[2].child.name
  end

  def test_error_invalid_attr
    doc = sax File.expand_path(File.dirname(__FILE__) + "/../../../xml/dtd_rule_test/error_invalid_attr.xml")
    ol = doc.topic.body.ol
    result = g.validate ol
    assert_equal false, result
    assert_equal :ValidateError, o.args[0]
    assert_equal GrammarClass, o.args[1].class
    assert_equal 'invalid_attr', o.args[2].attr_name
  end

  def test_error_invalid_attr_val
    doc = sax File.expand_path(File.dirname(__FILE__) + "/../../../xml/dtd_rule_test/error_invalid_attr_val.xml")
    t = doc.topic
    result = g.validate t
    assert_equal false, result
    assert_equal :ValidateError, o.args[0]
    assert_equal 'value_rule_class', o.args[1].simple_name
    assert_equal 'topic 1', o.args[2].value
  end

  def test_error_many_children_in_wrong_pos
    doc = sax File.expand_path(File.dirname(__FILE__) + "/../../../xml/dtd_rule_test/error_many_children_in_wrong_pos.xml")
    ol = doc.topic.body.ol
    result = g.validate ol
    assert_equal false, result
    assert_equal :ValidateError, o.args[0]
    assert_equal 'children_rule_class', o.args[1].simple_name
    assert_equal 2, o.args[2].index
  end

  def test_error_missing_attr
    doc = sax File.expand_path(File.dirname(__FILE__) + "/../../../xml/dtd_rule_test/error_missing_attr.xml")
    topic = doc.topic
    result = g.validate topic
    assert_equal false, result
    assert_equal :ValidateError, o.args[0]
    assert_equal 'attrs_rule_class', o.args[1].simple_name
    assert_equal 'id', o.args[2].attr_name
  end

  def test_error_no_children
    doc = sax File.expand_path(File.dirname(__FILE__) + "/../../../xml/dtd_rule_test/error_no_children.xml")
    ol = doc.topic.body.ol
    result = g.validate ol
    assert_equal false, result
    assert_equal :ValidateError, o.args[0]
    assert_equal 'children_rule_class', o.args[1].simple_name
    assert_equal 'li', o.args[2].missing_child
  end

  def test_error_no_valid_first_child
    doc = sax File.expand_path(File.dirname(__FILE__) + "/../../../xml/dtd_rule_test/error_no_valid_first_child.xml")
    ol = doc.topic.body.ol
    result = g.validate ol
    assert_equal false, result
    assert_equal :ValidateError, o.args[0]
    assert_equal 'children_rule_class', o.args[1].simple_name
    assert_equal 'li', o.args[2].missing_child
  end

  def test_interleaved_valid_children_text
    doc = sax File.expand_path(File.dirname(__FILE__) + "/../../../xml/dtd_rule_test/interleaved_valid_children_text.xml")

    p = doc.topic.body.p
    result = g.validate p
    assert_equal true, result
  end

  def test_plural_children
    doc = sax File.expand_path(File.dirname(__FILE__) + "/../../../xml/dtd_rule_test/plural_children.xml")
    ol = doc.topic.body.ol
    result = g.validate ol
    assert_equal true, result
  end

  def test_single_child
    doc = sax File.expand_path(File.dirname(__FILE__) + "/../../../xml/dtd_rule_test/single_child.xml")
    ol = doc.topic.body.ol
    result = g.validate ol
    assert_equal true, result
  end

  def tear_down
  end
end
