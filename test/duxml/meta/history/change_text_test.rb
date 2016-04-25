require File.expand_path(File.dirname(__FILE__) + '/../../../../lib/duxml/meta/history/change_text')
require File.expand_path(File.dirname(__FILE__) + '/../../../../lib/duxml/doc/element')
require 'test/unit'

class ChangeTextTest < Test::Unit::TestCase
  include Duxml

  def setup
    e = Element.new('parent', 66)
    e << Element.new('child')
    e << 'new text'
    @t = Time.now
    @v = ChangeTextClass.new(e, 1, 'old text')
  end

  attr_reader :v, :t

  def test_description
    assert_equal %(at #{t} on line 66: <parent>'s text at index 1 changed from 'old text' to 'new text'.), v.description
  end

  def tear_down
  end
end
