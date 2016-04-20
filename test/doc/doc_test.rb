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
  end


  def test_load_grammar
    Document.new()
  end

  def test_load_history

  end

  def test_all_nodes_observed

  end

  # Called after every test method runs. Can be used to tear
  # down fixture information.

  def teardown
    # Do nothing
  end
end