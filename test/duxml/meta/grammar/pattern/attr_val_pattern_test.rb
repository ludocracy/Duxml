# Copyright (c) 2016 Freescale Semiconductor Inc.
require File.expand_path(File.dirname(__FILE__) + '/../../../../../lib/duxml/meta/grammar/pattern/attr_val_pattern')
require File.expand_path(File.dirname(__FILE__) + '/../../../../../lib/duxml/doc/element')
require 'test/unit'

class AttrValPatternTest < Test::Unit::TestCase
  include Duxml

  def setup
    e = Element.new('root')
    e[:attr] = 'val'
    @p = AttrValPatternClass.new(e, :attr)
  end

  attr_reader :p

  def test_relationship
    assert_equal 'value', p.relationship
  end

  def test_description
    assert_equal %(<root>'s @attr value of 'val'), p.description
  end

  def tear_down
  end
end
