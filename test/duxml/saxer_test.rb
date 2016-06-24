# Copyright (c) 2016 Freescale Semiconductor Inc.

require File.expand_path(File.dirname(__FILE__) + '/../../lib/duxml/saxer')

require 'test/unit'

class Doc < ::Ox::Document

end

class SaxerTest < Test::Unit::TestCase
  include Duxml::Saxer
  # Called before every test method runs. Can be used
  # to set up fixture information.
  def setup
  end

  def test_line_counter
    doc = sax(File.expand_path(File.dirname(__FILE__) + '/../../xml/design.xml'))
    assert_equal 2, doc.design.line
    assert_equal 4, doc.design.legal_parent.also_legal_child.line
    assert_equal 6, doc.design.legal_parent.legal_child.line
  end

  def teardown
    # Do nothing
  end
end
