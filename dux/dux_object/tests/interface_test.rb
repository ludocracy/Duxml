require File.expand_path(File.dirname(__FILE__) + '/../../dux_object')
require 'minitest/autorun'
require 'nokogiri'
# tests term formatting - without regard to validity of evaluation
class InterfaceTest < MiniTest::Test
  SAMPLE_TEMPLATE_FILE = 'xml/sample_dux.xml'

  @e
  attr_reader :e
  def setup
    @e = DuxObject.new(%(<birdhouse id="birdhouse0" color="red" size="large"/>))
  end

  def test_to_s
    answer = %(<birdhouse color="red" id="birdhouse0" size="large"/>)
    assert_equal answer, e.to_s
  end

  def test_attributes
    h = e.attributes
    assert_equal 'birdhouse0', h[:id]
    assert_equal 'red', h[:color]
    assert_equal 'large', h[:size]
  end

  def test_promote_attr
    e.promote(:color)
    assert_equal 'color', e.first_child.type
  end

  def test_type
    a = DuxObject.new(%(<birdhouse id="poop" color="red" size="large"/>))
    assert_equal 'birdhouse', a.type
  end

  def test_add_child
    answer = %(<birdhouse color="red" id="birdhouse0" size="large"><material id="id0">pine</material></birdhouse>)
    e << DuxObject.new(%(<material id="id0">pine</material>))
    assert_equal answer, e.to_s
  end

  def test_add_children
    a = [DuxObject.new(%(<sub0/>)), DuxObject.new(%(<sub1/>)), DuxObject.new(%(<sub2/>))]
    e << a
    assert_equal 'sub0', e.children[0].type
    assert_equal 'sub1', e.children[1].type
    assert_equal 'sub2', e.children[2].type
  end

  def test_get_attr
    assert_equal 'large', e[:size]
  end

  def test_find_child
    t = DuxObject.new(%(<birdhouse><color/><material><wood>pine</wood></material></birdhouse>))
    assert_equal 'pine', t.find_child(%w(material wood)).content
  end

  def test_find_children
    t = DuxObject.new(%(<birdhouse><color/><material><wood id="part0">pine</wood><wood id="part1">oak</wood><nails id="part3">steel</wood></material></birdhouse>))
    woods = t.last_child.find_children :wood

    assert_equal 'wood', woods.last.type
    assert_equal 2, woods.size
  end

  def test_stub
    t = DuxObject.new(%(<birdhouse id="birdhouse0"><color/><material><wood>pine</wood></material></birdhouse>))
    s = t.stub
    assert_equal %(<birdhouse id="birdhouse0"/>), s.xml.to_s
    assert_equal 0, s.children.size
  end

  def test_remove
    t = DuxObject.new(%(<birdhouse id="birdhouse0"><color id="abc"/><material><wood>pine</wood></material></birdhouse>))
    c = t.find_child('material')
    t.remove c
    assert_equal %(<birdhouse id="birdhouse0"><color id="abc"/></birdhouse>), t.xml.to_s
  end

  def test_type_and_id
    t = DuxObject.new(%(<birdhouse id="jerrys">@(pine)<color/><material><wood>pine</wood></material></birdhouse>))
    assert_equal 'birdhouse', t.type
    assert_equal 'jerrys', t.id
  end

  def test_descended_from
    t = DuxObject.new(%(<birdhouse>@(pine)<color/><material><wood>pine</wood></material></birdhouse>))
    r = t.find_child(%w(material wood))
    assert_equal true, r.descended_from?(:birdhouse)
    assert_equal false, r.descended_from?(:color)
  end
end
