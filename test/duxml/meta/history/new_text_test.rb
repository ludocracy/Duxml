# Copyright (c) 2016 Freescale Semiconductor Inc.
require File.expand_path(File.dirname(__FILE__) + '/../../../../lib/duxml/meta/history/new_text')
require File.expand_path(File.dirname(__FILE__) + '/../../../../lib/duxml/doc/element')
require 'test/unit'

class NewTextTest < Test::Unit::TestCase
  include Duxml

  def setup
    e = Element.new('parent', 599)
    e << 'new text'
    @t = Time.now
    @v = NewTextClass.new(e, 0)
  end

  attr_reader :v, :t

  def test_description
    assert_equal %(at #{t} on line 599: <parent> given new text 'new text'.), v.description
  end

  def tear_down
  end
end
