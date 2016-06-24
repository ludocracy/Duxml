# Copyright (c) 2016 Freescale Semiconductor Inc.
require 'ox'
require File.expand_path(File.dirname(__FILE__) + '/../../../../../lib/duxml/meta/grammar/rule/value_rule')
require File.expand_path(File.dirname(__FILE__) + '/../../../../../lib/duxml/meta/history/new_attr')
require File.expand_path(File.dirname(__FILE__) + '/../../../../../lib/duxml/meta/history/change_attr')
require File.expand_path(File.dirname(__FILE__) + '/../../../../../lib/duxml/meta/grammar/pattern/attr_val_pattern')
require File.expand_path(File.dirname(__FILE__) + '/../../../../../lib/duxml/meta/grammar/pattern/attr_name_pattern')

require 'test/unit'

class Observer
  def update(*args)
    @args = args
  end

  attr_reader :args
end

class ValueRuleTest < Test::Unit::TestCase
  include Duxml
  include Ox

  def setup
    @rule = ValueRuleClass.new :foo, 'NMTOKEN'
    @x = Element.new('parent')
    @o = Observer.new
    @rule.add_observer o
  end

  attr_reader :rule, :x, :o

  def test_init_value_rule
    assert_equal 'value_rule_class', rule.simple_name
    assert_equal :foo, rule.attr_name
    assert_equal 'NMTOKEN', rule.statement
    assert_equal nil, rule.object
  end

  def test_relationship
    assert_equal 'value', rule.relationship
  end

  def test_description
    assert_equal "Value Rule that @foo's value must match 'NMTOKEN'", rule.description
  end

  def test_applies_to
    assert_equal true, rule.applies_to?(AttrValPatternClass.new(x, :foo))
    assert_equal true, rule.applies_to?(NewAttrClass.new(x, :foo))
    assert_equal true, rule.applies_to?(ChangeAttrClass.new(x, :foo, 'bar'))
    assert_equal false, rule.applies_to?(AttrNamePatternClass.new(x, :foo))
    assert_equal false, rule.applies_to?(AttrValPatternClass.new(x, :misc))
  end

  def test_qualify
    @x[:foo] = 'nmtoken'
    a = NewAttrClass.new(x, :foo)
    assert_equal true, rule.qualify(a)

    @x[:foo] = 'not nmtoken'
    a = ChangeAttrClass.new(x, :foo, 'identifier')
    assert_equal false, rule.qualify(a)
    assert_equal :QualifyError, o.args.first
  end

  def test_validate
    @x[:foo] = 'nmtoken'
    a = AttrValPatternClass.new(x, :foo)
    assert_equal true, rule.qualify(a)

    @x[:foo] = 'not nmtoken'
    a = AttrValPatternClass.new(x, :foo)
    assert_equal false, rule.qualify(a)
    assert_equal :ValidateError, o.args.first
  end

  def tear_down
  end
end
