require File.expand_path(File.dirname(__FILE__) + '/../lib/duxml')
require 'test/unit'

class DuxmlTest < Test::Unit::TestCase
  include Duxml

  # Called before every test method runs. Can be used
  # to set up fixture information.
  def setup

  end

  attr_reader :node

  def test_open_file
    # open xml file

    # check to see that metadata also opened
  end

  def test_save_file
    # save XML file

    # check to see that metadata also saved
  end

  def test_create_file

  end

  def test_grammar_found

  end

  def test_switch_grammar

  end

  # Called after every test method runs. Can be used to tear
  # down fixture information.

  def teardown
    # Do nothing
  end
end