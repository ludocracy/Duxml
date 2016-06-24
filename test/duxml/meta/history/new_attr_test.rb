# Copyright (c) 2016 Freescale Semiconductor Inc.
require File.expand_path(File.dirname(__FILE__) + '/../../../../lib/duxml/meta/history/new_attr')
require File.expand_path(File.dirname(__FILE__) + '/../../../../lib/duxml/doc/element')
require 'test/unit'

class NewAttrTest < Test::Unit::TestCase
  include Duxml

  def setup
    e = Element.new('parent', 599)
    e[:new_attr] = 'new_val'
    @t = Time.now
    @v = NewAttrClass.new(e, :new_attr)
  end

  attr_reader :v, :t

  def test_description
    assert_equal %(at #{t} on line 599: <parent> given new attribute 'new_attr' with value 'new_val'.), v.description
  end

  def tear_down
  end
end
