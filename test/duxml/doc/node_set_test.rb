# Copyright (c) 2016 Freescale Semiconductor Inc.
require File.expand_path(File.dirname(__FILE__) + '/../../../lib/duxml/doc/node_set')
require 'test/unit'

class Observer
  def update(*_args)
    @args = _args
  end
  attr_reader :args
end

class NodeSetTest < Test::Unit::TestCase
  include Duxml
  # Called before every test method runs. Can be used
  # to set up fixture information.
  def setup
    @o = Observer.new
  end

  attr_reader :o

  def test_parent
    ns = NodeSet.new('parent', ['foo', 'bar'])
    assert_equal 'foobar', ns.join
    assert_equal 'parent', ns.parent
  end

  def test_assign_str
    n = NodeSet.new('parent', ['foo', 'bar'])
    n.add_observer o
    n[0] = 'noo'
    assert_equal 'noobar', n.join
    assert_equal :ChangeText, o.args[0]
    assert_equal 'parent', o.args[1]
  end

  # Called after every test method runs. Can be used to tear
  # down fixture information.

  def teardown
    # Do nothing
  end
end