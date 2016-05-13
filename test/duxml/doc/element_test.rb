require File.expand_path(File.dirname(__FILE__) + '/../../../lib/duxml/doc/element')
require 'test/unit'

class Observer
  def update(*_args)
    @args = _args
  end
  attr_reader :args
end

class ElementTest < Test::Unit::TestCase
  include Duxml

  def setup
    @x = Element.new('root')
    x[:foot] = 'poot'
    x << Element.new('first') << Element.new('second')
    x.second << Element.new('third')
    x.second.third << 'some text'
    x.second << Element.new('fourth')
    @o = Observer.new
    x.traverse do |n|
      unless n.is_a?(String)
        n.add_observer o
        n.nodes.add_observer o
      end
    end
  end

  attr_accessor :x, :o

  def test_illegal_text
    f = x.second.fourth
    f << '& <&&'
    assert_equal '& <&&', f.text
  end

  def test_description
    assert_equal '<root>', x.description
  end

  def test_history
    assert_equal Observer, x.history.class
  end

  def test_name_space
    y = Element.new('duxml:doc')
    assert_equal 'duxml', y.name_space
  end

  def test_location
    y = Element.new('node', 999, 888)
    assert_equal 999, y.line
    assert_equal 888, y.column
  end

  def test_each
    res = x.collect do |child| child.name end
    assert_equal %w(first second), res
  end

  def test_traverse
    res = []
    x.traverse do |node| res << node.name if node.is_a?(Element) end
    assert_equal %w(root first second third fourth), res
  end

  def test_add
    x << Element.new('fifth')
    assert_equal :Add, o.args[0]
    assert_equal 'root', o.args[1].name
    assert_equal 2, o.args[2]
  end

  def test_remove
    f = x.second.fourth
    assert_equal f, x.second.delete(f)
    assert_equal :Remove, o.args[0]
    assert_equal 'second', o.args[1].name
    assert_equal 'fourth', o.args[2].name
  end

  def test_change_attr
    x[:foot] = :coot
    assert_equal :ChangeAttr, o.args[0]
    assert_equal 'root', o.args[1].name
    assert_equal 'foot', o.args[2]
    assert_equal 'poot', o.args[3]
  end

  def test_new_attr
    x[:cork] = :pork
    assert_equal :NewAttr, o.args[0]
    assert_equal 'root', o.args[1].name
    assert_equal 'cork', o.args[2]
  end

  def test_add_text
    x << 'some text'
    assert_equal 'some text', x.nodes.last
    assert_equal :NewText, o.args[0]
    assert_equal 'root', o.args[1].name
    assert_equal 2, o.args[2]
  end

  def test_add_array
    x << ['some text', Element.new('interloper'), 'more text']
    assert_equal 'some text', x.nodes[-3]
    assert_equal 'interloper', x.nodes[-2].name
    assert_equal 'more text', x.nodes[-1]
  end

  def test_detach_nodes
    t = Element.new('test')
    t << x.nodes
    assert_equal 'first', t.nodes[0].name
    assert_equal 'second', t.nodes[1].name
  end

  def test_change_text
    t = x.second.third
    t.nodes[0] = "new text"
    assert_equal 'new text', x.second.third.nodes[0]
    assert_equal :ChangeText, o.args[0]
    assert_equal 'third', o.args[1].name
    assert_equal 0, o.args[2]
    assert_equal 'some text', o.args[3]
  end

  def tear_down
  end
end
