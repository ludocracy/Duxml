require File.expand_path(File.dirname(__FILE__) + '/../../lib/duxml/doc')
require 'test/unit'

class Observer
  def update(*_args)
    @args = _args
  end
  attr_reader :args
end

class DocTest < Test::Unit::TestCase
  include Duxml
  # Called before every test method runs. Can be used
  # to set up fixture information.
  def setup
    @x = Duxml::Doc.new
  end

attr_reader :x

  def test_to_s
    x << Element.new('design')
    assert_equal "@root='<design>'>", x.to_s[-17..-1]
  end

  def test_node_set
    assert_equal NodeSet, x.nodes.class
  end

  # Called after every test method runs. Can be used to tear
  # down fixture information.

  def teardown

  end
end