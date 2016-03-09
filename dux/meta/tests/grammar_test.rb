require File.expand_path(File.dirname(__FILE__) + '/../../meta')
require 'minitest/autorun'

class GrammarTest < MiniTest::Test
  def setup
    sample_template = File.expand_path(File.dirname(__FILE__) + '/../../../dux/tests/xml/sample_meta.xml')
    @meta = Meta.new sample_template
    @schema_rule = Rule.new element 'rule', {subject: 'thing'}, '%w(legal_child).include? object.type'
    @content_rule = Rule.new element 'rule', {subject: 'target'}, %(subject.content != 'something something')
    @change = NewContent.new nil, {subject: meta.design.find_child(:targetiddxcz), object: ''}
    meta.history.add change, 0
  end

  attr_reader :meta, :schema_rule, :content_rule, :change

  def test_init_pattern
    p = Pattern.new meta.design.find_child 'targetiddxcz'
    assert_equal 'pattern', p.type
    assert_equal 'targetiddxcz', p.subject(meta).id
    assert_equal nil, p.object
    # test compare
  end

  def test_rule
    assert_equal 'rule', schema_rule.type
    assert_equal 'rule', content_rule.type
    assert_equal true, schema_rule.qualify(change)
    assert_equal false, content_rule.qualify(change)
  end

  def test_grammar_qualify
    meta.grammar << schema_rule
    illegal_child = DuxObject.new(element 'illegal_child')
    legal_child = DuxObject.new(element 'legal_child')
    target = meta.design.find_child(:thing1)
    target << illegal_child
    target << legal_child
    assert_equal 'qualify_error', meta.history[1].type
    assert_equal 'illegal_child', meta.history[1].non_compliant_change.object.type
  end

  def test_grammar_validate
    meta.grammar << content_rule
    target = meta.design.find_child(:targetiddxcz)
    meta.grammar.validate target
    assert_equal 'validate_error', meta.history.first.type
  end

  def tear_down
  end
end
