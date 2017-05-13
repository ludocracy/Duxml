# Copyright (c) 2016 Freescale Semiconductor Inc.
require File.expand_path(File.dirname(__FILE__) + '/../../../../../lib/duxml/meta/grammar/relax_ng/children_rule')
require File.expand_path(File.dirname(__FILE__) + '/../../../../../lib/duxml/meta/grammar')

require 'test/unit'

class RelaxNGTest < Test::Unit::TestCase
  include Duxml

  def setup
    @g = GrammarClass.new
  end

  attr_reader :g

  def test_star_children
    g << ChildrenRuleClass.new('star', 'child*')
    rng = g.relaxng
    nodes = rng.root.Define(name: 'star')
    assert_equal 1, nodes.size
    assert_equal 1, nodes.first.nodes.size
    assert_equal 'zeroOrMore', nodes.first.element.zeroOrMore.name
  end

  def test_optional_child
    g << ChildrenRuleClass.new('optional', 'child?')
    rng = g.relaxng
    nodes = rng.root.Define(name: 'optional')
    assert_equal 1, nodes.size
    assert_equal 1, nodes.first.nodes.size
    assert_equal 'optional', nodes.first.element.optional.name
  end

  def test_required_child
    g << ChildrenRuleClass.new('required', 'child')
    rng = g.relaxng
    nodes = rng.root.Define(name: 'required')
    assert_equal 1, nodes.size
    assert_equal 1, nodes.first.nodes.size
    assert_equal 'ref', nodes.first.element.ref.name
  end

  def test_plus_children
    g << ChildrenRuleClass.new('plus', 'child+')
    rng = g.relaxng
    nodes = rng.root.Define(name: 'plus')
    assert_equal 1, nodes.size
    assert_equal 1, nodes.first.nodes.size
    assert_equal 'oneOrMore', nodes.first.element.oneOrMore.name
  end

  def test_multiple_children
    g << ChildrenRuleClass.new('star', '(son|daughter)*')
    rng = g.relaxng
    nodes = rng.root.Define(name: 'star')
    assert_equal 1, nodes.size
    zom = nodes.first.element.zeroOrMore.choice.Ref()
    assert_equal 2, zom.size
  end

  def test_child_rule_stacking
    g << ChildrenRuleClass.new('plus', 'child+')
    rng = g.relaxng
    nodes = rng.root.Define(name: 'child').collect do |d| d.element end
    assert_equal 'child', nodes.first['name']

    g << ChildrenRuleClass.new('child', 'grandchild')
    rng = g.relaxng
    nodes = rng.root.Define(name: 'child').collect do |d| d.element end
    assert_equal 1, nodes.size

    nodes0 = rng.root.Define(name: 'grandchild').collect do |d| d.element end
    assert_equal 'grandchild', nodes0.first['name']
  end

  def tear_down
  end
end
