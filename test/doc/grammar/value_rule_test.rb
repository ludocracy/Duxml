require File.expand_path(File.dirname(__FILE__) + '/../../../lib/duxml/doc/grammar/rule/value_rule')
require File.expand_path(File.dirname(__FILE__) + '/../../../lib/duxml/doc/history/new_attribute')
require File.expand_path(File.dirname(__FILE__) + '/../../../lib/duxml/doc/history/change_attribute')
require File.expand_path(File.dirname(__FILE__) + '/../../../lib/duxml/doc/grammar/pattern/attr_val_pattern')
require File.expand_path(File.dirname(__FILE__) + '/../../../lib/duxml/doc/grammar/pattern/attr_name_pattern')

require 'test/unit'

class Observer
  def update(*args)
    @args = args
  end

  attr_reader :args
end

class ValueRuleTest < Test::Unit::TestCase
  include Duxml

  def setup
    @rule = Duxml::ValueRule.new :foo, 'NMTOKEN'
    @x = Element.new('parent')
    @o = Observer.new
    @rule.add_observer o
  end

  attr_reader :rule, :x, :o

  def test_init_value_rule
    assert_equal 'value_rule', rule.simple_name
    assert_equal :foo, rule.attr_name
    assert_equal 'NMTOKEN', rule.statement
    assert_equal nil, rule.object
  end

  def test_applies_to
    assert_equal true, rule.applies_to?(Duxml::AttrValPattern.new(x, :foo))
    assert_equal true, rule.applies_to?(Duxml::NewAttribute.new(x, :foo))
    assert_equal true, rule.applies_to?(Duxml::ChangeAttribute.new(x, :foo, 'bar'))
    assert_equal false, rule.applies_to?(Duxml::AttrNamePattern.new(x, :foo))
    assert_equal false, rule.applies_to?(Duxml::AttrValPattern.new(x, :misc))
  end

  def test_qualify
    @x[:foo] = 'nmtoken'
    a = Duxml::NewAttribute.new(x, :foo)
    assert_equal true, rule.qualify(a)

    @x[:foo] = 'not nmtoken'
    a = Duxml::ChangeAttribute.new(x, :foo, 'identifier')
    assert_equal false, rule.qualify(a)
    assert_equal :qualify_error, o.args.first
  end

  def test_validate
    @x[:foo] = 'nmtoken'
    a = Duxml::AttrValPattern.new(x, :foo)
    assert_equal true, rule.qualify(a)

    @x[:foo] = 'not nmtoken'
    a = Duxml::AttrValPattern.new(x, :foo)
    assert_equal false, rule.qualify(a)
    assert_equal :validate_error, o.args.first
  end

  def tear_down
  end
end
