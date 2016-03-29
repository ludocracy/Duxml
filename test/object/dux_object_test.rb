require File.expand_path(File.dirname(__FILE__) + '/../../lib/dux/object')
require 'minitest/autorun'

# test term formatting - without regard to validity of evaluation
class DuxObjectTest < MiniTest::Test
  def setup
  end

  def test_init_nil
   assert_equal 'object', Dux::Object.new(nil).type
  end

  def test_init_text_child
    e = Dux::Object.new %(<coop>text</coop>)
    assert %(<coop>text</coop>), e.xml.to_s
  end

  def test_mixed_content
    e = Dux::Object.new %(<coop>text<interloper/>more text</coop>)
    assert_equal 3, e.children.size
    assert_equal 'text', e.first_child.content
    assert_equal 'interloper', e.children[1].type
    assert_equal 'more text', e.last_child.content
  end

  def test_init_str
    test_xml = Nokogiri::XML(%(<coop id="cooper0"/>)).root
    e = Dux::Object.new(test_xml.to_s)
    assert_equal test_xml.to_s, e.xml.to_s
  end

  def test_init_simple
    test_xml = Nokogiri::XML(%(<coop id="cooper0"/>)).root
    e = Dux::Object.new(test_xml)
    assert_equal test_xml.to_s, e.xml.to_s
  end

  def test_init_attr
    test_xml = Nokogiri::XML(%(<coop id="cooper0" color=\"green\"/>)).root
    e = Dux::Object.new(test_xml.to_s)
    assert_equal test_xml.to_s, e.xml.to_s
    assert_equal "green", e[:color].to_s
  end

  def test_init_content
    test_xml = Nokogiri::XML(%(<coop id="cooper0">cooper</coop>)).root
    e = Dux::Object.new(test_xml)
    assert_equal 'cooper', e.content
  end

  def test_init_hierarchy
    e = Dux::Object.new(%(<coop id="cooper0"><danglers id="danglers0">dangling</danglers><chunks id="chunk0">chunky</chunks></coop>))
    child0 = e.find_child(:danglers)
    child1 = e.find_child(:chunks)
    assert_equal %(<danglers id="danglers0">dangling</danglers>), child0.xml.to_s
    assert_equal %(<chunks id="chunk0">chunky</chunks>), child1.xml.to_s
    assert_equal 'danglers', child0.simple_class
  end

  def tear_down

  end

end # end of RewriterTest
