# Copyright (c) 2016 Freescale Semiconductor Inc.
require 'ox'
require File.expand_path(File.dirname(__FILE__) + '/../../../../../lib/duxml/meta/grammar/rule/children_rule')
require File.expand_path(File.dirname(__FILE__) + '/../../../../../lib/duxml/meta/history/add')
require File.expand_path(File.dirname(__FILE__) + '/../../../../../lib/duxml/meta/grammar/pattern/child_pattern')

require 'test/unit'

class Observer
  def update(*args)
    @args = args
  end

  attr_reader :args
end

class ChildrenRuleTest < Test::Unit::TestCase
  include Duxml
  include Ox

  def setup
    @rule = ChildrenRuleClass.new 'parent', '((<one> | <two> | <four> | #PCDATA))*'
    @o = Observer.new
    rule.add_observer o
    @x = Element.new('parent') << 'some_text' << Element.new('one')
    @cr = Element.new('children_rule')
    cr[:subject] = 'parent'
    cr[:statement] = '((\\bone\\b|\\btwo\\b|\\bfour\\b|\\b#PCDATA\\b))*'
  end

  attr_reader :rule, :o, :x, :cr

  def test_dynamic_module_extension
    assert_equal rule.subject, cr.subject
    assert_equal rule.statement, cr.statement
  end

  def test_init_child_rule
    assert_equal 'children_rule_class', rule.simple_name
    assert_equal 'parent', rule.subject
    assert_equal '((\\bone\\b|\\btwo\\b|\\bfour\\b|\\b#PCDATA\\b))*', rule.statement
    assert_equal nil, rule.object
  end

  def test_validate
    p = ChildPatternClass.new(x, x.one, 1)
    result = rule.qualify p
    assert_equal true, result

    x << Element.new('three')
    c = ChildPatternClass.new(x, x.three, 2)
    result = rule.qualify c
    assert_equal false, result
    assert_equal :ValidateError, o.args.first
  end

  def test_qualify
    c = AddClass.new(x, x.one, 1)
    result = rule.qualify c
    assert_equal true, result

    x << Element.new('three')
    p = AddClass.new(x, x.three, 2)
    result = rule.qualify p
    assert_equal false, result
    assert_equal :QualifyError, o.args.first
  end

  def test_relationship
    assert_equal 'children', rule.relationship
  end

  def test_description
    assert_equal "Children Rule that <parent>'s children must match '((one|two|four|#PCDATA))*'", rule.description
  end

  def test_applies_to
    subj = Element.new('parent') << Element.new('primus') << Element.new('secundus')
    assert_equal true, rule.applies_to?(ChildPatternClass.new(subj, subj.primus, 0))
    assert_equal true, rule.applies_to?(ChildPatternClass.new(subj, subj.secundus, 1))
    assert_equal false, rule.applies_to?(ChildPatternClass.new(Element.new('node'), nil, 0))
  end

  def tear_down
  end
end
