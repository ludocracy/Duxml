require File.expand_path(File.dirname(__FILE__) + '/../../dux/meta')
require 'minitest/autorun'

class MetaTest < MiniTest::Test
  attr_reader :meta

  def setup
    sample_template = File.expand_path(File.dirname(__FILE__) + '/../../dux/tests/xml/sample_meta.xml')
    @meta = Meta.new sample_template
  end

  def test_init_non_compliant_xml
    t = Meta.new element 'test_element'
    assert_equal 'test_element', t.design.children.first.type
  end

  def test_meta_history
    a = meta.history.children.first.type
    assert_equal 'insert', a
  end

  def test_meta_grammar
    a = meta.grammar.type
    assert_equal 'grammar', a
  end

  def tear_down
  end
end
