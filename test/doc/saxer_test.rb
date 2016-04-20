require File.expand_path(File.dirname(__FILE__) + '/../../lib/duxml/doc/saxer')
require File.expand_path(File.dirname(__FILE__) + '/../../lib/duxml/doc/history')

require 'test/unit'

class SaxerTest < Test::Unit::TestCase
  include Saxer
  # Called before every test method runs. Can be used
  # to set up fixture information.
  def setup
  end

  attr_accessor :history, :io

  def test_line_counter
    @history = Duxml::History.xml
    @io = File.open File.expand_path(File.dirname(__FILE__) + '/../../xml/design.xml')
    doc = sax(Ox::Document.new)
    assert_equal 2, doc.design.line
    assert_equal 4, doc.design.legal_parent.also_legal_child.line
    assert_equal 6, doc.design.legal_parent.legal_child.line
  end

  def teardown
    # Do nothing
  end
end
