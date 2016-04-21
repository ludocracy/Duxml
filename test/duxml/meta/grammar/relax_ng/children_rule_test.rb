require File.expand_path(File.dirname(__FILE__) + '/../../../../../lib/duxml/meta/grammar/relax_ng/children_rule')
require 'test/unit'

class RelaxNGTest < Test::Unit::TestCase
  include Duxml

  def setup
    @g = Grammar.new
  end

  attr_reader :g

  def test_star_children
    g << Duxml::ChildrenRule.new('star', 'child*')
    rng = g.relaxng
    nodes = rng.css("doc[@name='star']")
    assert_equal 1, nodes.size
    assert_equal 1, nodes.first.element_children.size
    assert_equal 'zeroOrMore', nodes.first.element_children.first.name
  end

  def test_bang_child
    g << Duxml::ChildrenRule.new('bang', 'child?')
    rng = g.relaxng
    nodes = rng.css('doc[@name="bang"]')
    assert_equal 1, nodes.size
    assert_equal 1, nodes.first.element_children.size
    assert_equal 'optional', nodes.first.element_children.first.name
  end

  def test_required_child
    g << Duxml::ChildrenRule.new('required', 'child')
    rng = g.relaxng
    nodes = rng.css("doc[@name='required']")
    assert_equal 1, nodes.size
    assert_equal 1, nodes.first.element_children.size
    assert_equal 'ref', nodes.first.element_children.first.name
  end

  def test_plus_children
    g << Duxml::ChildrenRule.new('plus', 'child+')
    rng = g.relaxng
    nodes = rng.css("doc[@name='plus']")
    assert_equal 1, nodes.size
    assert_equal 1, nodes.first.element_children.size
    assert_equal 'oneOrMore', nodes.first.element_children.first.name
  end

  def test_multiple_children
    g << Duxml::ChildrenRule.new('star', '(son|daughter)*')
    rng = g.relaxng
    nodes = rng.css("doc[@name='star']")
    assert_equal 1, nodes.size
    zom = nodes[0].css("zeroOrMore")
    assert_equal 1, zom.size
    assert_equal 2, zom.css('/choice/ref').size
  end

  def test_child_rule_stacking
    g << Duxml::ChildrenRule.new('plus', 'child+')
    rng = g.relaxng
    nodes = rng.css("define[@name='child']/doc")
    assert_equal 'child', nodes.first['name']

    g << Duxml::ChildrenRule.new('child', 'grandchild')
    rng = g.relaxng
    nodes = rng.css("define[@name='child']/doc")
    assert_equal 1, nodes.size

    nodes0 = rng.css("define[@name='grandchild']/doc")
    assert_equal 'grandchild', nodes0.first['name']
  end

  def tear_down
  end
end
