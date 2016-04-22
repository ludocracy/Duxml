require 'ox'
require File.expand_path(File.dirname(__FILE__) + '/../../../../lib/duxml/meta/grammar/rule')
require File.expand_path(File.dirname(__FILE__) + '/../../../../lib/duxml/meta/history/change')

require 'test/unit'
include Duxml
class TestRulePattern < PatternClass
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
  include Ox

  def setup
    @rule = RuleClass.new('parent', 'statement')
    @o = Observer.new
    rule.add_observer o
  end

  attr_reader :rule, :o

  def test_qualify
    result = rule.qualify ChangeClass.new(Element.new('barney'))
    assert_equal false, result
    assert_equal :qualify_error, o.args.first

    result = rule.qualify TestRulePattern.new(Element.new('barney'))
    assert_equal false, result
    assert_equal :validate_error, o.args.first
  end

  def test_statement
    assert_equal 'statement', rule.statement
  end

  def test_object_nil
    assert_equal false, rule.object.is_a?(Element)
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
