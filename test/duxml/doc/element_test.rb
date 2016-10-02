# Copyright (c) 2016 Freescale Semiconductor Inc.
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
    @x = Element.new('root', {foot: 'poot'}, [Element.new('first'), Element.new('second')])
    x.second << Element.new('third', ['some text'])
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

  def test_index_or_attr
    assert_equal 'poot', x[:foot]
    assert_equal 'poot', x['foot']
    assert_equal 'second', x[1].name
  end

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

  def test_stub
    s = x.stub
    assert_equal '<root foot="poot"/>', s.to_s
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
    x.first << Element.new('three-halves')
    x.traverse do |node| res << node.name if node.is_a?(Element) end
    assert_equal %w(root first three-halves second third fourth), res
  end

  def test_add
    x << Element.new('fifth')
    assert_equal :Add, o.args[0]
    assert_equal 'root', o.args[1].name
    assert_equal '<fifth/>', o.args[2].to_s
  end

  def test_add_xml_from_str
    x << '<fifth/>'
    assert_equal '<fifth/>', x.fifth.to_s
  end


  def test_text?
    e = x.second.third
    assert_equal true, e.text?
    e << Element.new('interloper')
    assert_equal false, e.text?
  end

  def test_sclone
    e_clone = x.sclone
    assert_not_same x, e_clone
    assert_equal '<root foot="poot"/>', e_clone.to_s


    sclone_w_text = x.second.third.sclone
    assert_equal '<third>some text</third>', sclone_w_text.to_s
  end

  def test_dclone
    x << Element.new('fifth')
    e_clone = x.dclone
    assert_not_same x, e_clone
    assert_equal x.to_s, e_clone.to_s
    assert_not_same x[0], e_clone[0]
    assert_not_same x[1], e_clone[1]
    assert_not_same x[2], e_clone[2]

    assert_equal '<root foot="poot"><first/><second><third>some text</third><fourth/></second><fifth/></root>', x.to_s
  end

  def test_replace
    x[0] = 'coot'
    x[1] = 'moot'
    assert_equal '<root foot="poot">cootmoot</root>', x.to_s
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

  def test_nil_attr
    x[:null] = nil
    assert_equal '<root foot="poot"/>', x.stub.to_s

    x[:foot] = nil
    assert_equal '<root/>', x.stub.to_s
  end

  def test_add_text
    x << 'some text'
    assert_equal 'some text', x.nodes.last
    assert_equal :NewText, o.args[0]
    assert_equal 'root', o.args[1].name
    assert_equal 'some text', o.args[2]
  end

  def test_add_array
    x << ['some text', Element.new('interloper'), 'more text']
    assert_equal 'some text', x.nodes[-3]
    assert_equal 'interloper', x.nodes[-2].name
    assert_equal 'more text', x.nodes[-1]
    x.add(%w(one two three), 1)
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
