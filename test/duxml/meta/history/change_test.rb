require File.expand_path(File.dirname(__FILE__) + '/../../../../lib/duxml/meta/history/change')
require File.expand_path(File.dirname(__FILE__) + '/../../../../lib/duxml/doc/element')
require 'test/unit'

class ChangeTest < Test::Unit::TestCase
  include Duxml

  def setup
    e = Element.new('parent')
    c = Element.new('child1', 10)
    @t = Time.now
    @v = ChangeClass.new(e, c)
  end

  attr_reader :v, :t

  def test_description
    assert_equal %(at #{t} on line 10:), v.description
  end

  def tear_down
  end
end
