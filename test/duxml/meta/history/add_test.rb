require File.expand_path(File.dirname(__FILE__) + '/../../../../lib/duxml/meta/history/add')
require File.expand_path(File.dirname(__FILE__) + '/../../../../lib/duxml/doc/element')
require 'test/unit'

class AddTest < Test::Unit::TestCase
  include Duxml

  def setup
    e = Element.new('parent', 599)
    e << Element.new('child1', 600)
    @t = Time.now
    @v = AddClass.new(e, 0)
  end

  attr_reader :v, :t

  def test_description
    assert_equal %(at #{t} on line 600: <child1> added to <parent>.), v.description
  end

  def tear_down
  end
end
