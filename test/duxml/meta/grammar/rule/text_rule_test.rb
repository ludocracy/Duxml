require File.expand_path(File.dirname(__FILE__) + '/../../../../../lib/duxml/meta/grammar/rule/text_rule')
require File.expand_path(File.dirname(__FILE__) + '/../../../../../lib/duxml/meta/history/new_text')
require File.expand_path(File.dirname(__FILE__) + '/../../../../../lib/duxml/meta/history/change_text')
require File.expand_path(File.dirname(__FILE__) + '/../../../../../lib/duxml/meta/grammar/pattern/text_pattern')
require 'ox'
require 'test/unit'

class Observer
  def update(*args)
    @args = args
  end

  attr_reader :args
end

class TextRuleTest < Test::Unit::TestCase
  include Duxml
  include Ox

  def setup
    @rule = Duxml::TextRuleClass.new 'parent', Regexp.identifier
    @x = Element.new('parent')
    @o = Observer.new
    @rule.add_observer o
  end

  attr_reader :rule, :x, :o

  def test_init_text_rule
    assert_equal 'text_rule_class', rule.simple_name
    assert_equal 'parent', rule.subject
    assert_equal Regexp.identifier, rule.statement
    assert_equal nil, rule.object
  end

  def test_applies_to
    assert_equal true, rule.applies_to?(Duxml::TextPatternClass.new(x, 0))
    assert_equal true, rule.applies_to?(Duxml::NewTextClass.new(x, 0))
    assert_equal true, rule.applies_to?(Duxml::ChangeTextClass.new(x, 0, 'old text'))
    assert_equal false, rule.applies_to?(Duxml::NewTextClass.new(Element.new('foo'), 0))
  end

  def test_qualify
    x << 'identifier'
    a = Duxml::NewTextClass.new(x, 0)
    assert_equal true, rule.qualify(a)

    x.nodes[0]= 'not identifier'
    a = Duxml::ChangeTextClass.new(x, 0, 'identifier')
    assert_equal false, rule.qualify(a)
    assert_equal :qualify_error, o.args.first
  end

  def test_validate
    x << 'identifier'
    a = Duxml::TextPatternClass.new(x, 0)
    assert_equal true, rule.qualify(a)

    x.nodes[0] = 'not identifier'
    a = Duxml::TextPatternClass.new(x, 1)
    assert_equal false, rule.qualify(a)
    assert_equal :validate_error, o.args.first
  end

  def tear_down
  end
end
