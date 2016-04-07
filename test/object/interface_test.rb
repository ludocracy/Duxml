require File.expand_path(File.dirname(__FILE__) + '/../../lib/duxml/object')
require 'minitest/autorun'
require 'nokogiri'
# tests term formatting - without regard to validity of evaluation
class InterfaceTest < MiniTest::Test
  @e
  attr_reader :e
  def setup
    @e = Duxml::Object.new(%(<birdhouse id="birdhouse0" color="red" size="large"/>))
  end

  def test_to_s
    answer = %(<birdhouse color="red" id="birdhouse0" size="large"/>)
    assert_equal answer, e.to_s
  end

  def test_add_text_content
    @e << 'blah blah blah'
    assert_equal 'blah blah blah', e.content
  end

  def test_attributes
    h = e.attributes
    assert_equal 'birdhouse0', h[:id]
    assert_equal 'red', h[:color]
    assert_equal 'large', h[:size]
  end

  def test_position
    t = Duxml::Object.new(%(<birdhouse><color/><material><wood id="part0">pine</wood><wood id="part1">oak</wood><nails id="part3">steel</nails></material></birdhouse>))
    c = t.find_child(%w(material nails))
    assert_equal 2, c.position
  end

  def test_type
    a = Duxml::Object.new(%(<birdhouse id="poop" color="red" size="large"/>))
    assert_equal 'birdhouse', a.type
  end

  def test_add_child
    answer = %(<birdhouse color="red" id="birdhouse0" size="large"><material id="id0">pine</material></birdhouse>)
    new_child = Duxml::Object.new(%(<material id="id0">pine</material>))
    @e << new_child
    assert_equal answer, e.to_s
  end

  def test_add_children
    a = [Duxml::Object.new(%(<sub0/>)), Duxml::Object.new(%(<sub1/>)), Duxml::Object.new(%(<sub2/>))]
    @e << a
    assert_equal 'sub0', e.children[0].type
    assert_equal 0, e.children[0].position
    assert_equal 'sub1', e.children[1].type
    assert_equal 'sub2', e.children[2].type
  end

  def test_line

  end

  def test_xml
    a = Duxml::Object.new(%(<sub id="sub0">some text</sub>))
    assert_equal 'p_c_data', a.children.first.simple_class
    assert_equal %(<sub id="sub0">some text</sub>), a.xml.to_s
  end

  def test_content
    a = Duxml::Object.new(%(<sub id="sub0">some text</sub>))
    assert_equal 'some text', a.content
  end

  def test_get_attr
    assert_equal 'large', e[:size]
  end

  def test_find_child
    t = Duxml::Object.new(%(<birdhouse><color/><material><wood>pine</wood></material></birdhouse>))
    assert_equal 'pine', t.find_child(%w(material wood)).content
  end

  def test_find_children
    t = Duxml::Object.new(%(<birdhouse><color/><material><wood id="part0">pine</wood><wood id="part1">oak</wood><nails id="part3">steel</nails></material></birdhouse>))
    woods = t.last_child.find_children :wood

    assert_equal 'wood', woods.last.type
    assert_equal 2, woods.size
  end

  def test_remove
    t = Duxml::Object.new(%(<birdhouse id="birdhouse0"><color id="abc"/><material><wood>pine</wood></material></birdhouse>))
    c = t.find_child('material')
    t.remove c
    assert_equal %(<birdhouse id="birdhouse0"><color id="abc"/></birdhouse>), t.xml.to_s
  end

  def test_type_and_id
    t = Duxml::Object.new(%(<birdhouse id="jerrys">@(pine)<color/><material><wood>pine</wood></material></birdhouse>))
    assert_equal 'birdhouse', t.type
    assert_equal 'jerrys', t.id
  end

  def test_descended_from
    t = Duxml::Object.new(%(<birdhouse>@(pine)<color/><material><wood>pine</wood></material></birdhouse>))
    r = t.find_child(%w(material wood))
    assert_equal true, r.descended_from?(:birdhouse)
    assert_equal false, r.descended_from?(:color)
  end
end
