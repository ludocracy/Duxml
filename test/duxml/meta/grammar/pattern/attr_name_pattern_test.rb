# Copyright (c) 2016 Freescale Semiconductor Inc.
require File.expand_path(File.dirname(__FILE__) + '/../../../../../lib/duxml/meta/grammar/pattern/attr_name_pattern')
require File.expand_path(File.dirname(__FILE__) + '/../../../../../lib/duxml/doc/element')
require 'test/unit'

class AttrNamePatternTest < Test::Unit::TestCase
  include Duxml

  def setup
    e = Element.new('root')
    e[:attr] = 'val'
    @p = AttrNamePatternClass.new(e, :attr)
    @q = AttrNamePatternClass.new(e, :missing)
  end

  attr_reader :p, :q

  def test_relationship
    assert_equal 'attribute', p.relationship
  end

  def test_description
    assert_equal %(<root>'s attribute [attr]), p.description
    assert_equal %(<root> does not have attribute [missing]), q.description
  end

  def tear_down
  end
end
