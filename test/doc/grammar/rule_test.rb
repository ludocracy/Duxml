require File.expand_path(File.dirname(__FILE__) + '/../../../lib/duxml/doc/grammar/rule')
require File.expand_path(File.dirname(__FILE__) + '/../../../lib/duxml/doc/history/change')

require 'test/unit'

class TestRule
  include Duxml::Rule
  def initialize(*args)
    @subject = args.first
  end
end

class TestRulePattern
  include Duxml::Pattern
  def initialize(*args)
    @subject = args.first
  end
end

class Observer
  def update(*args)
    @args = args
  end

  attr_reader :args
end

class RuleTest < Test::Unit::TestCase
  include Duxml

  def setup
    @rule = TestRule.new('parent')
    @o = Observer.new
    rule.add_observer o
  end

  attr_reader :rule, :o

  def test_qualify
    result = rule.qualify Duxml::Change.new(Duxml::Element.new('barney'))
    assert_equal false, result
    assert_equal :qualify_error, o.args.first

    result = rule.qualify TestRulePattern.new(Duxml::Element.new('barney'))
    assert_equal false, result
    assert_equal :validate_error, o.args.first
  end

  def test_applies_to
    subj = Element.new('parent') << Element.new('primus')
    assert_equal true, rule.applies_to?(TestRulePattern.new(subj))
    assert_equal false, rule.applies_to?(TestRulePattern.new(Element.new('child')))
    assert_equal false, rule.applies_to?(TestRulePattern.new(subj.primus))
  end

  def tear_down
  end
end
