require File.expand_path(File.dirname(__FILE__) + '/../../../lib/duxml/doc/grammar/rule/attributes_rule')
require File.expand_path(File.dirname(__FILE__) + '/../../../lib/duxml/doc/history/new_attribute')
require File.expand_path(File.dirname(__FILE__) + '/../../../lib/duxml/doc/grammar/pattern/attr_name_pattern')

require 'test/unit'

class Observer
  def update(*args)
    @args = args
  end

  attr_reader :args
end

class AttributesRuleTest < Test::Unit::TestCase
  include Duxml

  def setup
    @rule = Duxml::AttributesRule.new 'parent', 'foo', '#REQUIRED'
    @x = Element.new('parent')
    @o = Observer.new
    @rule.add_observer o
  end

  attr_reader :rule, :x, :o

  def test_init_attributes_rule
    assert_equal 'attributes_rule', rule.simple_name
    assert_equal 'parent', rule.subject
    assert_equal 'foo', rule.attr_name
    assert_equal '\\bfoo\\b', rule.statement
    assert_equal '#REQUIRED', rule.requirement
    assert_equal nil, rule.object
  end

  def test_applies_to
    assert_equal true, rule.applies_to?(Duxml::AttrNamePattern.new(x, :foo))
    assert_equal true, rule.applies_to?(Duxml::NewAttribute.new(x, :foo))
    assert_equal false, rule.applies_to?(Duxml::AttrNamePattern.new(x, :bar))
  end

  def test_qualify
    a = Duxml::NewAttribute.new(x, :foo)
    assert_equal true, rule.qualify(a)

    a = Duxml::NewAttribute.new(x, :bird)
    assert_equal false, rule.qualify(a)
    assert_equal :qualify_error, o.args.first
  end

  def test_validate
    a = Duxml::AttrNamePattern.new(x, :bird)
    assert_equal false, rule.qualify(a)
    assert_equal :validate_error, o.args.first

    x[:bird] = 'word'
    assert_equal true, rule.qualify(a)
  end

  def tear_down
  end
end
