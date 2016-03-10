require File.expand_path(File.dirname(__FILE__) + '/../history')
require File.expand_path(File.dirname(__FILE__) + '/../../../dux/meta')
require 'minitest/autorun'
require 'nokogiri'

class HistoryTest < MiniTest::Test
  def setup
    f = File.expand_path(File.dirname(__FILE__) + '/../../tests/xml/sample_meta.xml')
    @t = Meta.new f
  end

  attr_accessor :t

  def test_add_child
    new_kid = DuxObject.new(%(<test id="test_0"/>))
    t.design << new_kid
    c = t.history.first
    assert_equal 'insert', c.type
    assert_equal %(Element 'test_0' of type 'test' was added to element 'design_id' of type 'design'.), c.description
  end

  def test_remove_child
    t.design.remove 'thing1'
    c = t.history.first
    assert_equal 'remove', c.type
    assert_equal %(Element 'thing1' of type 'thing' was removed from element 'design_id' of type 'design'.), c.description
  end

  def test_new_attr
    t
    t.design.find_child('thing1')[:new_attribute] = 'new value'
    c = t.history.first
    assert_equal 'new_attribute', c.type
    assert_equal %(Element 'thing1' of type 'thing' given new attribute 'new_attribute' with value 'new value'.), c.description
  end

  def test_new_content
    t.design.find_child('thing1').content = 'new content'
    c = t.history.first
    assert_equal 'new_content', c.type
    assert_equal %(Element 'thing1' of type 'thing' given new content 'new content'.), c.description
  end

  def test_change_attr
    t.design.find_child('thing1')[:visible] = 'new value'
    c = t.history.first
    assert_equal 'change_attribute', c.type
    assert_equal %(Element 'thing1' of type 'thing' changed attribute 'visible' value from 'asdf' to 'new value'.), c.description
  end

  def test_change_content
    t.design.find_child('targetiddxcz').content = 'new content'
    c = t.history.first
    assert_equal 'change_content', c.type
    assert_equal %(Element 'targetiddxcz' of type 'target' changed content from 'something something' to 'new content'.), c.description
  end

  def test_change_param

  end

  def test_change_order
    # check to make sure changes are stacked latest first, first last
  end

  def tear_down
  end
end
