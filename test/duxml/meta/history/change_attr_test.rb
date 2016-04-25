require File.expand_path(File.dirname(__FILE__) + '/../../../../lib/duxml/meta/history/change_attr')
require File.expand_path(File.dirname(__FILE__) + '/../../../../lib/duxml/doc/element')
require 'test/unit'

class ValidateErrorTest < Test::Unit::TestCase
  include Duxml

  def setup
    e = Element.new('parent', 101)
    e[:foo] = 'new value'
    @t = Time.now
    @v = ChangeAttrClass.new(e, :foo, 'old value')
  end

  attr_reader :v, :t

  def test_description
    assert_equal %(at #{t} on line 101: <parent>'s @foo changed value from 'old value' to 'new value'.), v.description
  end

  def tear_down
  end
end
