# Copyright (c) 2016 Freescale Semiconductor Inc.
require File.expand_path(File.dirname(__FILE__) + '/../../../../../lib/duxml/meta/grammar/pattern/child_pattern')
require File.expand_path(File.dirname(__FILE__) + '/../../../../../lib/duxml/doc/element')
require 'test/unit'

class ChildPatternTest < Test::Unit::TestCase
  include Duxml

  def setup
    e = Element.new('parent')
    e << Element.new('child')
    @p = ChildPatternClass.new(e, e.child, 0)
    @q = NullChildPatternClass.new(e, 'missing')
  end

  attr_reader :p, :q

  def test_relationship
    assert_equal 'first child', p.relationship
    assert_equal 'missing child', q.relationship
  end

  def test_description
    assert_equal %(<parent>'s first child <child>), p.description
    assert_equal %(<parent> missing child <missing>), q.description
  end

  def tear_down
  end
end
