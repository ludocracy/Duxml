# Copyright (c) 2016 Freescale Semiconductor Inc.
require File.expand_path(File.dirname(__FILE__) + '/../../../../lib/duxml/meta/history/error')
require File.expand_path(File.dirname(__FILE__) + '/../../../../lib/duxml/meta/grammar/pattern/child_pattern')
require File.expand_path(File.dirname(__FILE__) + '/../../../../lib/duxml/meta/grammar/rule/children_rule')
require File.expand_path(File.dirname(__FILE__) + '/../../../../lib/duxml/doc/element')
require 'test/unit'

class ErrorTest < Test::Unit::TestCase
  include Duxml

  def setup
    p = Element.new('parent', 599)
    p << Element.new('child1', 600)
    p << Element.new('what', 601)
    rule = ChildrenRuleClass.new('parent', 'child1|child2')
    pattern = ChildPatternClass.new(p, p[1], 1)
    @e = ErrorClass.new(rule, pattern)
  end

  attr_reader :e

  def test_rule
    assert_same e.subject, e.rule
  end

  def test_error
    assert_equal true, e.error?
  end

  def tear_down
  end
end
