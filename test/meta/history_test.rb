require File.expand_path(File.dirname(__FILE__) + '/../../lib/dux')
require 'minitest/autorun'

class HistoryTest < MiniTest::Test
  include Dux
  def setup
    f = File.expand_path(File.dirname(__FILE__) + '/../../xml/design.xml')
    @t = load f
  end

  attr_accessor :t

  def test_add_child
    new_kid = Dux::Object.new(%(<test id="test_0"/>))
    t.design << new_kid
    c = t.history.first
    assert_equal 'add', c.type
    assert_equal %(Element 'test_0' of type 'test' was added to element 'design_id' of type 'design'.), c.description
  end

  def test_remove_child
    t.design.remove 'legal_parent'
    c = t.history.first
    assert_equal 'remove', c.type
    assert_equal %(Element 'lp_0' of type 'legal_parent' was removed from element 'design_id' of type 'design'.), c.description
  end

  def test_new_attr
    t
    t.design.find_child(%w(legal_parent also_legal_child))[:new_attribute] = 'new value'
    c = t.history.first
    assert_equal 'new_attribute', c.type
    assert_equal %(Element 'alc_0' of type 'also_legal_child' given new attribute 'new_attribute' with value 'new value'.), c.description
  end

  def test_new_content
    t.design.find_child(%w(legal_parent also_legal_child)).content = 'new content'
    c = t.history.first
    assert_equal 'new_content', c.type
    assert_equal %(Element 'alc_0' of type 'also_legal_child' given new content 'new content'.), c.description
  end

  def test_change_attr
    t.design.find_child(%w(legal_parent legal_child))[:visible] = 'new value'
    c = t.history.first
    assert_equal 'change_attribute', c.type
    assert_equal %(Element 'lc_0' of type 'legal_child' changed attribute 'visible' value from 'nope' to 'new value'.), c.description
  end

  def test_change_content
    t.design.find_child(%w(legal_parent legal_child)).content = 'new content'
    c = t.history.first
    assert_equal 'change_content', c.type
    assert_equal %(Element 'lc_0' of type 'legal_child' changed content from 'text content' to 'new content'.), c.description
  end

  def tear_down
  end
end
