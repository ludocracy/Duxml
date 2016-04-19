require File.expand_path(File.dirname(__FILE__) + '/../../lib/duxml/history')
require 'test/unit'

class HistoryTest < Test::Unit::TestCase
  include Duxml
  def setup
  end

  def test_add_child
    new_kid = Duxml::Object.new(%(<object id="test_0"/>))
    current_meta.design << new_kid
    c = current_meta.history.first
    assert_equal 'add', c.type
  end

  def test_remove_child
    current_meta.design.remove 'legal_parent'
    c = current_meta.history.first
    assert_equal 'remove', c.type
  end

  def test_new_attr
    current_meta.design.find_child(%w(legal_parent also_legal_child))[:new_attribute] = 'new value'
    c = current_meta.history.first
    assert_equal 'new_attribute', c.type
  end

  def test_new_content
    current_meta.design.find_child(%w(legal_parent also_legal_child)).content = 'new content'
    c = current_meta.history.first
    assert_equal 'new_content', c.type
  end

  def test_change_attr
    current_meta.design.find_child(%w(legal_parent legal_child))[:visible] = 'new value'
    c = current_meta.history.first
    assert_equal 'change_attribute', c.type
  end

  def test_change_content
    current_meta.design.find_child(%w(legal_parent legal_child)).content = 'changed content'
    c = current_meta.history.first
    assert_equal 'change_content', c.type
  end

  def tear_down
  end
end
