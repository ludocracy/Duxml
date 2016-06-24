# Copyright (c) 2016 Freescale Semiconductor Inc.
require File.expand_path(File.dirname(__FILE__) + '/../../../../lib/duxml/meta/grammar')
require 'test/unit'

class PatternMakerTest < Test::Unit::TestCase
  include Duxml
  include Grammar

  def setup
    rules = [ChildrenRuleClass.new('parent', 'required_child, optional_child*'),
             AttrsRuleClass.new('parent', 'required', '#REQUIRED')]

    @g = GrammarClass.new(rules)
    @x = Element.new('parent')
    x[:bogus] = 'wtvr'
    x << Element.new('optional_child') << Element.new('unexpected_child')
  end

  attr_reader :g, :x

  def test_get_relationships
    a = g.get_relationships(x)
    assert_equal 6, a.size
  end

  def test_get_existing_attr_patterns
    a = g.get_existing_attr_patterns(x)
    assert_equal 'bogus', a.first.attr_name
    assert_equal 'bogus', a[1].attr_name
  end
  %(<parent bogus="wtvr"><optional_child/><unexpected_child/></parent>)
  def test_get_null_attr_patterns
    a = g.get_null_attr_patterns(x)
    assert_equal 'required', a.first.attr_name
  end

  def test_get_null_child_patterns
    a = g.get_null_child_patterns(x)
    assert_equal 'required_child', a.first.missing_child
  end

  def test_get_child_patterns
    a = g.get_child_patterns(x)
    assert_equal 'optional_child', a.first.child.name
    assert_equal 'unexpected_child', a.last.child.name
    assert_equal 0, a.first.index
    assert_equal 1, a.last.index
  end

  def tear_down
  end
end
