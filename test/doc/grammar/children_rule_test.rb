require File.expand_path(File.dirname(__FILE__) + '/../../../lib/duxml/doc/grammar/rule/children_rule')
require File.expand_path(File.dirname(__FILE__) + '/../../../lib/duxml/doc/history/add')
require File.expand_path(File.dirname(__FILE__) + '/../../../lib/duxml/doc/grammar/pattern/child_pattern')

require 'test/unit'

class Observer
  def update(*args)
    @args = args
  end

  attr_reader :args
end

class ChildrenRuleTest < Test::Unit::TestCase
  include Duxml

  def setup
    # TODO split this up into separate tests!!!
    @rule = ChildrenRule.new 'parent', '((<one> | <two> | <four> | #PCDATA))*'
    @o = Observer.new
    rule.add_observer o
    @x = Element.new('parent') << 'some_text' << Element.new('one')
  end

  attr_reader :rule, :o, :x

  def test_init_child_rule
    assert_equal 'children_rule', rule.simple_name
    assert_equal 'parent', rule.subject
    assert_equal '((\\bone\\b|\\btwo\\b|\\bfour\\b|\\bp_c_data\\b))*', rule.statement
    assert_equal nil, rule.object
  end

  def test_validate
    p = ChildPattern.new(x, 1)
    result = rule.qualify p
    assert_equal true, result

    x << Element.new('three')
    c = ChildPattern.new(x, 2)
    result = rule.qualify c
    assert_equal false, result
    assert_equal :validate_error, o.args.first
  end

  def test_qualify
    c = Add.new(x, 1)
    result = rule.qualify c
    assert_equal true, result

    x << Element.new('three')
    p = Add.new(x, 2)
    result = rule.qualify p
    assert_equal false, result
    assert_equal :qualify_error, o.args.first
  end

  def test_applies_to
    subj = Element.new('parent') << Element.new('primus') << Element.new('secundus')
    assert_equal true, rule.applies_to?(ChildPattern.new(subj, 0))
    assert_equal true, rule.applies_to?(ChildPattern.new(subj, 1))
    assert_equal false, rule.applies_to?(ChildPattern.new(Element.new('node'), 0))
  end

  def tear_down
  end
end
