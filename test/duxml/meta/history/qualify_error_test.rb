# Copyright (c) 2016 Freescale Semiconductor Inc.
require File.expand_path(File.dirname(__FILE__) + '/../../../../lib/duxml/meta/history/qualify_error')
require File.expand_path(File.dirname(__FILE__) + '/../../../../lib/duxml/meta/grammar/rule/children_rule')
require File.expand_path(File.dirname(__FILE__) + '/../../../../lib/duxml/meta/grammar/pattern/child_pattern')
require 'test/unit'

class QualifyErrorTest < Test::Unit::TestCase
  include Duxml

  def setup
    e = Element.new('parent', 599)
    e << Element.new('child1', 600)
    e << Element.new('what', 601)
    rule = ChildrenRuleClass.new('parent', 'child1|child2')
    pattern = ChildPatternClass.new(e, e[1], 1)
    @t = Time.now
    @q = QualifyErrorClass.new(rule, pattern)
  end

  attr_reader :q, :t

  def test_description
    assert_equal %(Qualify Error at #{t} on line 601: <parent>'s second child <what> violates Children Rule that <parent>'s children must match 'child1|child2'.), q.description
  end

  def tear_down
  end
end
