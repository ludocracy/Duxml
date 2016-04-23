require File.expand_path(File.dirname(__FILE__) + '/../../lib/duxml/meta')
require 'test/unit'

class MetaTest < Test::Unit::TestCase
  include Duxml
  include Ox
  def setup
    @g_path = File.expand_path(File.dirname(__FILE__) + '/../../xml/test_grammar.xml')
    @m = MetaClass.new(g_path)
    @x = Meta.xml
  end

  attr_reader :x, :m, :g_path

  def test_init_no_grammar
    ng = MetaClass.new
    assert_equal false, ng.grammar.defined?
    ng.grammar = g_path
    assert_equal true, ng.grammar.defined?
  end

  def test_xml
    assert_equal 'duxml:meta', x.root.name
    assert_equal 'grammar', x.root.nodes.first.name
    assert_equal 'duxml:history', x.root.nodes[1].name
  end

  def test_update
    assert_equal true, m.grammar.respond_to?(:qualify)
    assert_equal true, m.history.respond_to?(:update)
  end

  def test_observer_status
    res = m.grammar.rules.any? do |r|
      r.history != m.history
    end
    assert_equal false, res
    assert_equal m.grammar, m.history.grammar
  end

  def test_meta_path
    path = 'C:/test/file.xml'
    assert_equal 'C:/test/.file.xml.duxml', Meta.meta_path(path)
  end

  def tear_down
  end
end
