# Copyright (c) 2016 Freescale Semiconductor Inc.
require File.expand_path(File.dirname(__FILE__) + '/../../../../lib/duxml/meta/history/validate_error')
require File.expand_path(File.dirname(__FILE__) + '/../../../../lib/duxml/meta/grammar/rule/children_rule')
require File.expand_path(File.dirname(__FILE__) + '/../../../../lib/duxml/meta/grammar/pattern/child_pattern')
require 'test/unit'

class ValidateErrorTest < Test::Unit::TestCase
  include Duxml

  def setup
    e = Element.new('parent', 599)
    e << Element.new('child1', 600)
    e << Element.new('what', 601)
    rule = ChildrenRuleClass.new('parent', 'child1|child2')
    pattern = ChildPatternClass.new(e, 1)
    @t = Time.now
    @v = ValidateErrorClass.new(rule, pattern)
  end

  attr_reader :v, :t

  def test_description
    assert_equal %(Validate Error at #{t} on line 601: <parent>'s second child <what> violates Children Rule that <parent>'s children must match 'child1|child2'.), v.description
  end

  def tear_down
  end
end
