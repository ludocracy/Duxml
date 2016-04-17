require File.expand_path(File.dirname(__FILE__) + '/../../../lib/duxml/meta/grammar')
require 'minitest/autorun'

class RelaxNGTest < MiniTest::Test
  include Duxml

  def setup
    @g = Grammar.new
    g << Duxml::ChildrenRule.new('node', 'EMPTY')
  end

  attr_reader :g

  def test_required_attribute_relaxng
    g << Duxml::AttributesRule.new('node', 'required', '#REQUIRED')

    # first reference
    rng = g.relaxng
    assert_equal 'required', rng.css("element[@name='node']/ref").last['name']

    # first def
    nodes = rng.css("attribute[@name='required']")
    assert_equal 'attribute', nodes.first.name
    assert_equal 1, nodes.size

    g << Duxml::ValueRule.new('required', 'CDATA')
    rng = g.relaxng

    # still there?
    nodes = rng.css("attribute[@name='required']")
    assert_equal 'attribute', nodes.first.name
    assert_equal 1, nodes.size

    # value
    assert_equal 'data', nodes.first.element_children.last.name
    assert_equal 1, nodes.first.element_children.size
  end

  def test_enumerated_values_attr_relaxng
    g << Duxml::AttributesRule.new('node', 'required', '#REQUIRED')
    g << Duxml::ValueRule.new('required', '(asdf|fdsa)')
    rng = g.relaxng
    nodes = rng.css("attribute[@name='required']/choice/value")

    assert_equal 2, nodes.size
  end

  def test_name_rule_stacking
    g << Duxml::AttributesRule.new('node', 'required', '#REQUIRED')
    g << Duxml::AttributesRule.new('node', 'required', '#REQUIRED')
    g << Duxml::AttributesRule.new('node', 'required', '#REQUIRED')
    rng = g.relaxng
    nodes = rng.css("attribute[@name='required']")

    assert_equal 1, nodes.size
  end

  def test_value_rule_stacking
    g << Duxml::AttributesRule.new('node', 'required', '#REQUIRED')
    g << Duxml::ValueRule.new('required', 'CDATA')
    g << Duxml::ValueRule.new('required', 'CDATA')
    g << Duxml::ValueRule.new('required', 'CDATA')
    rng = g.relaxng
    nodes = rng.css("attribute[@name='required']/data")

    assert_equal 1, nodes.size
  end

  def test_implied_attribute_relaxng
    g << Duxml::AttributesRule.new('node', 'implied', '#IMPLIED')
    rng = g.relaxng
    nodes = rng.css("element[@name='node']/optional/ref")
    assert_equal 'implied', nodes.last['name']

    g << Duxml::AttributesRule.new('node', 'unknown', '"-')
    rng = g.relaxng
    nodes = rng.css("element[@name='node']/optional/ref")
    assert_equal 'unknown', nodes.last['name']
  end

  def tear_down
  end
end
