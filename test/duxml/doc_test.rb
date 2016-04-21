require File.expand_path(File.dirname(__FILE__) + '/../../lib/duxml/doc')
require 'test/unit'

class Observer
  def update(*_args)
    @args = _args
  end
  attr_reader :args
end

class DocumentTest < Test::Unit::TestCase
  include Duxml
  # Called before every test method runs. Can be used
  # to set up fixture information.
  def setup
    file_name = 'design.xml'
    path = File.expand_path(File.dirname(__FILE__) + "/../../xml/#{file_name}")
    @x = Duxml::Doc.new path
  end

attr_reader :x

  # TODO not sure what we need to test here. that Doc inherited Duxml and Document successfully?

  # Called after every test method runs. Can be used to tear
  # down fixture information.

  def teardown

  end
end