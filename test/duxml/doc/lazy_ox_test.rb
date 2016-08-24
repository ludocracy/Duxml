# Copyright (c) 2016 Freescale Semiconductor Inc.
require File.expand_path(File.dirname(__FILE__) + '/../../../lib/duxml/doc/lazy_ox')
require 'ox'
require 'test/unit'

module Duxml
  class El < ::Ox::Element
    include LazyOx

    def simple_name
      name.split(':').last
    end
  end

  module Root
    def foo
      'hi!'
    end
  end
end

class Generic
  include Duxml::LazyOx
  def initialize(*a)
    @nodes = a
  end

  attr_reader :nodes
end

class Duck
  def name; 'duck' end
end

class Goose;
  def name; 'goose' end
end

module Outer
  module Inner
    def doit
      'hi!'
    end
  end
end

class LazyOxTest < Test::Unit::TestCase
  include Duxml
  include Ox

  def setup
    @x = El.new('root')
  end

  attr_accessor :x

  def test_module_extension
    assert_equal 'hi!', x.foo
  end

  def test_module_nesting_main_module
    outer = El.new('outer:inner')
    assert_equal 'hi!', outer.doit
  end

  def test_module_nesting_duxml
    outer = El.new('duxml:root')
    assert_equal 'hi!', outer.foo
  end

  def test_module_nesting_default
    outer = El.new('root')
    assert_equal 'hi!', outer.foo
  end

  def test_no_method_error
    assert_raise(NoMethodError, "undefined method `asdf' for class `Duxml::El'") do x.asdf end
  end

  def test_class_match_array
    g = Generic.new(Duck.new, Goose.new, Goose.new)
    a = g.Goose
    assert_equal 2, a.size
    assert_equal "goose", a.first.name
    assert_equal "goose", a[1].name
  end

  def test_element_name_array
    #unfiltered
    %w(one two two two).each do |name| x << El.new(name) end
    a = x.two
    assert_equal x.nodes[1], a
    a = x.Two
    assert_equal x.nodes[1], a.first
    a = x.Two
    assert_equal x.nodes[3], a.last

    #filtered by member
    a.first[:attr] = 'val'
    a.last[:attr] = 'value'
    assert_equal [a.first, a.last], x.Two(:attr)

    #filtered by member value
    assert_equal [a.first], x.Two(attr: 'val')

    #selected by block
    assert_equal [a.first], x.Two{|n| n[:attr] == 'val'}
  end

  def test_namespaced_children
    r = El.new('asdf:root') << El.new('asdf:child')
    c = r.child
    assert_equal 'asdf:child', c.value
  end

  def test_misnavigation
    %w(one two two two).each do |name| x << El.new(name) end
    assert_raise(NoMethodError) do x.three end

    o = El.new('outer:inner_fake') << El.new('coo')
    assert_raise(NoMethodError) do o.coo.yeah end
  end

  def tear_down
  end
end