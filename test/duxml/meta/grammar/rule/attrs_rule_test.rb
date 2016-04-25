require 'ox'
require File.expand_path(File.dirname(__FILE__) + '/../../../../../lib/duxml/meta/grammar/rule/attrs_rule')
require File.expand_path(File.dirname(__FILE__) + '/../../../../../lib/duxml/meta/history/new_attr')
require File.expand_path(File.dirname(__FILE__) + '/../../../../../lib/duxml/meta/grammar/pattern/attr_name_pattern')

require 'test/unit'

class Observer
  def update(*args)
    @args = args
  end

  attr_reader :args
end

class AttrsRuleTest < Test::Unit::TestCase
  include Duxml
  include Ox

  def setup
    @rule = AttrsRuleClass.new 'parent', 'foo', '#REQUIRED'
    @x = Element.new('parent')
    @o = Observer.new
    @rule.add_observer o
  end

  attr_reader :rule, :x, :o

  def test_init_attributes_rule
    assert_equal 'attrs_rule_class', rule.simple_name
    assert_equal 'parent', rule.subject
    assert_equal 'foo', rule.attr_name
    assert_equal '\\bfoo\\b', rule.statement
    assert_equal '#REQUIRED', rule.requirement
    assert_equal nil, rule.object
  end

  def test_applies_to
    assert_equal true, rule.applies_to?(AttrNamePatternClass.new(x, :foo))
    assert_equal true, rule.applies_to?(NewAttrClass.new(x, :foo))
    assert_equal false, rule.applies_to?(AttrNamePatternClass.new(x, :bar))
  end

  def test_qualify
    a = NewAttrClass.new(x, :foo)
    assert_equal true, rule.qualify(a)

    a = NewAttrClass.new(x, :bird)
    assert_equal false, rule.qualify(a)
    assert_equal :QualifyError, o.args.first
  end

  def test_relationship
    assert_equal 'attributes', rule.relationship
  end

  def test_description
    assert_equal "Attributes Rule that <parent>'s attributes must include 'foo'", rule.description
  end

  def test_validate
    a = AttrNamePatternClass.new(x, :bird)
    assert_equal false, rule.qualify(a)
    assert_equal :ValidateError, o.args.first

    x[:bird] = 'word'
    assert_equal true, rule.qualify(a)
  end

  def tear_down
  end
end
