# Copyright (c) 2016 Freescale Semiconductor Inc.
require File.expand_path(File.dirname(__FILE__) + '/../../../../../lib/duxml/meta/grammar/pattern/text_pattern')
require File.expand_path(File.dirname(__FILE__) + '/../../../../../lib/duxml/doc/element')
require 'test/unit'

class TextPatternTest < Test::Unit::TestCase
  include Duxml

  def setup
    e = Element.new('parent')
    e << 'some text'
    @p = TextPatternClass.new(e, 'some text', 0)
  end

  attr_reader :p

  def test_relationship
    assert_equal 'text', p.relationship
  end

  def test_description
    assert_equal %(<parent>'s text is 'some text'), p.description
  end

  def tear_down
  end
end
