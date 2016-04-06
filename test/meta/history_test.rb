require File.expand_path(File.dirname(__FILE__) + '/../../lib/dux')
require 'minitest/autorun'

class HistoryTest < MiniTest::Test
  include Dux
  def setup
    f = File.expand_path(File.dirname(__FILE__) + '/../../xml/design.xml')
    load f
  end

  def test_add_child
    new_kid = Dux::Object.new(%(<test id="test_0"/>))
    current_meta.design << new_kid
    c = current_meta.history.first
    assert_equal 'add', c.type
    assert_equal %(<test id="test_0"> was added to <design id="design_id">.), c.description
  end

  def test_remove_child
    current_meta.design.remove 'legal_parent'
    c = current_meta.history.first
    assert_equal 'remove', c.type
    assert_equal %(<legal_parent id="lp_0"> was removed from <design id="design_id">.), c.description
  end

  def test_new_attr
    current_meta.design.find_child(%w(legal_parent also_legal_child))[:new_attribute] = 'new value'
    c = current_meta.history.first
    assert_equal 'new_attribute', c.type
    assert_equal %(<also_legal_child id="alc_0"> given new attribute 'new_attribute' with value 'new value'.), c.description
  end

  def test_new_content
    current_meta.design.find_child(%w(legal_parent also_legal_child)).content = 'new content'
    c = current_meta.history.first
    assert_equal 'new_content', c.type
    assert_equal %(<also_legal_child id="alc_0"> given new content 'new content'.), c.description
  end

  def test_change_attr
    current_meta.design.find_child(%w(legal_parent legal_child))[:visible] = 'new value'
    c = current_meta.history.first
    assert_equal 'change_attribute', c.type
    assert_equal %(<legal_child id="lc_0"> changed attribute 'visible' value from 'nope' to 'new value'.), c.description
  end

  def test_change_content
    current_meta.design.find_child(%w(legal_parent legal_child)).content = 'changed content'
    c = current_meta.history.first
    assert_equal 'change_content', c.type
    assert_equal %(<legal_child id="lc_0"> changed content from 'text content' to 'changed content'.), c.description
  end

  def tear_down
  end
end
