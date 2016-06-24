# Copyright (c) 2016 Freescale Semiconductor Inc.
require File.expand_path(File.dirname(__FILE__) + '/../../../../lib/duxml/meta/history/remove')
require File.expand_path(File.dirname(__FILE__) + '/../../../../lib/duxml/doc/element')
require 'test/unit'

class RemoveTest < Test::Unit::TestCase
  include Duxml

  def setup
    e = Element.new('parent')
    r = Element.new('child1', 999)
    @t = Time.now
    @v = RemoveClass.new(e, r)
  end

  attr_reader :v, :t

  def test_description
    assert_equal %(at #{t} on line 999: <child1> removed from <parent>.), v.description
  end

  def tear_down
  end
end
