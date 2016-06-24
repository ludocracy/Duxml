# Copyright (c) 2016 Freescale Semiconductor Inc.
require File.expand_path(File.dirname(__FILE__) + '/../../../../../lib/duxml/meta/grammar/relax_ng/attrs_rule')
require File.expand_path(File.dirname(__FILE__) + '/../../../../../lib/duxml/meta/grammar')

require 'test/unit'

class RelaxNGTest < Test::Unit::TestCase
  include Duxml

  def setup
    @g = GrammarClass.new
    g << ChildrenRuleClass.new('node', '')
  end

  attr_reader :g

  def test_required_attribute_relaxng
    g << AttrsRuleClass.new('node', 'required', '#REQUIRED')

    # first reference
    rng = g.relaxng
    nodes = rng.root.Define(name: 'node')
    assert_equal 'required', nodes.first.element.ref[:name]

    # first def
    nodes = rng.root.Define(name: 'required')
    assert_equal 'attribute', nodes.first.attribute.name
    assert_equal 1, nodes.size

    g << ValueRuleClass.new('required', 'CDATA')
    rng = g.relaxng

    # still there?
    nodes = rng.root.Define(name: 'required')
    assert_equal 'attribute', nodes.first.attribute.name
    assert_equal 1, nodes.size

    # value
    assert_equal 'data', nodes.first.attribute.data.name
    assert_equal 1, nodes.first.nodes.size
  end

  def test_enumerated_values_attr_relaxng
    g << AttrsRuleClass.new('node', 'required', '#REQUIRED')
    g << ValueRuleClass.new('required', '(asdf|fdsa)')
    rng = g.relaxng
    nodes = rng.root.Define(name: 'required').first.attribute.choice.Value()

    assert_equal 2, nodes.size
  end

  def test_name_rule_stacking
    g << AttrsRuleClass.new('node', 'required', '#REQUIRED')
    g << AttrsRuleClass.new('node', 'required', '#REQUIRED')
    g << AttrsRuleClass.new('node', 'required', '#REQUIRED')
    rng = g.relaxng
    nodes = rng.root.Define(name: 'required')

    assert_equal 1, nodes.size
  end

  def test_value_rule_stacking
    g << AttrsRuleClass.new('node', 'required', '#REQUIRED')
    g << ValueRuleClass.new('required', 'CDATA')
    g << ValueRuleClass.new('required', 'CDATA')
    g << ValueRuleClass.new('required', 'CDATA')
    rng = g.relaxng
    nodes = rng.root.Define(name: 'required').first.attribute.Data()

    assert_equal 1, nodes.size
  end

  def test_implied_attribute_relaxng
    g << AttrsRuleClass.new('node', 'implied', '#IMPLIED')
    rng = g.relaxng
    nodes = rng.root.Define(name: 'node').first.element.optional.Ref()
    assert_equal 'implied', nodes.last[:name]

    g << AttrsRuleClass.new('node', 'unknown', '"-')
    rng = g.relaxng
    nodes = rng.root.Define(name: 'node').first.element.optional.Ref()
    assert_equal 'unknown', nodes.last[:name]
  end

  def tear_down
  end
end
