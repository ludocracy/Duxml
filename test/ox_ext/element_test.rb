require File.expand_path(File.dirname(__FILE__) + '/../../lib/duxml/ox_ext/element')
require 'test/unit'


class ElementTest < Test::Unit::TestCase
  include Ox

  def setup
    @x = xml %(<root foot="poot"><first/><second><third>some text</third><fourth/></second></root>)
    @o = Observer.new
    x.traverse do |n| n.add_observer o end
  end

  attr_accessor :x, :o

  def test_location
    # TODO assign location and have it repeat it back
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
    x << '<fifth/>'
    assert_equal :Add, o.args[0]
    assert_equal 'root', o.args[1].name
    assert_equal 'fifth', o.args[2].name
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
    assert_equal :ChangeAttribute, o.args[0]
    assert_equal 'root', o.args[1].name
    assert_equal :foot, o.args[2]
    assert_equal 'poot', o.args[3]
  end

  def test_new_attr
    x[:cork] = :pork
    assert_equal :NewAttribute, o.args[0]
    assert_equal 'root', o.args[1].name
    assert_equal :cork, o.args[2]
  end

  def test_add_text
    x << 'some text'
    assert_equal 'some text', x.nodes.last
    assert_equal :NewText, o.args[0]
    assert_equal 'root', o.args[1].name
    assert_equal 'some text', o.args[2]

  end

  def test_change_text
    t = x.second.third
    t.nodes[0] = "new text"
    assert_equal 'new text', x.second.third.nodes[0]
    assert_equal :ChangeText, o.args[0]
    assert_equal 'third', o.args[1].name
    assert_equal 'some text', o.args[2]
  end

  def tear_down
  end
end
