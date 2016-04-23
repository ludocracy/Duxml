require File.expand_path(File.dirname(__FILE__) + '/../../../lib/duxml/meta/history')
require 'test/unit'

class Observer
  def update(*args)
    @args = args
  end
end

class HistoryTest < Test::Unit::TestCase
  include Duxml
  def setup
    @history = HistoryClass.new
    @x = Element.new('x')
    x << Element.new('a')
    x << Element.new('b')
    x.a << 'old text'
    x.a[:var_attr] = 'old_value'
    history.add_observer Observer.new
    x.traverse do |n|
      n.add_observer history unless n.is_a?(String)
    end
  end

  attr_accessor :history, :x

  def test_xml
    assert_equal 'duxml:history', History.xml.name
  end

  def test_grammar
    assert_equal Observer, history.grammar.class
  end

  def test_add_child
    new_kid = Element.new('c')
    x << new_kid
    c = history[0]
    assert_equal 'duxml:add_class', c.class.to_s.nmtokenize
  end

  def test_remove_child
    x.delete x.b
    c = history[0]
    assert_equal 'duxml:remove_class', c.class.to_s.nmtokenize
  end

  def test_new_attr
    x.b[:new_attribute] = 'new value'
    c = history[0]
    assert_equal 'duxml:new_attr_class', c.class.to_s.nmtokenize
  end

  def test_new_text
    x.b << 'new content'
    c = history[0]
    assert_equal 'duxml:new_text_class', c.class.to_s.nmtokenize
  end

  def test_change_attr
    x.a[:var_attr] = 'new_value'
    c = history[0]
    assert_equal 'duxml:change_attr_class', c.class.to_s.nmtokenize
  end

  def test_change_text
    x.a.nodes[0] = 'new text'
    c = history[0]
    assert_equal 'duxml:change_text_class', c.class.to_s.nmtokenize
  end

  def tear_down
  end
end
