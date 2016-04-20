require File.expand_path(File.dirname(__FILE__) + '/../../lib/duxml/doc')
require 'test/unit'

class Observer
  def update(*_args)
    @args = _args
  end
  attr_reader :args
end


class DocumentTest < Test::Unit::TestCase
  include Ox
  # Called before every test method runs. Can be used
  # to set up fixture information.
  def setup
    file_name = 'design.xml'
    path = File.expand_path(File.dirname(__FILE__) + "/../../xml/#{file_name}")
    @meta_path = File.expand_path(File.dirname(__FILE__) + "/../../xml/.#{file_name}.duxml")
    @x = Duxml::Doc.new path
  end
attr_reader :x, :meta_path

  def test_load_grammar
    assert_equal 'grammar', x.grammar.name
  end

  def test_load_history
    assert_equal 'history', x.history.name
    assert_equal 'grammar', x.grammar.name
  end

  def test_all_nodes_observed
    x.traverse do |n|
      assert_equal 1, n.count_observers, "node #{Ox.dump n} does not have an observer!"
    end
  end

  # Called after every test method runs. Can be used to tear
  # down fixture information.

  def teardown
    File.delete meta_path
  end
end