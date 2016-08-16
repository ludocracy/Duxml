# Copyright (c) 2016 Freescale Semiconductor Inc.

require File.expand_path(File.dirname(__FILE__) + '/../../lib/duxml/meta')
require 'test/unit'

class MetaTest < Test::Unit::TestCase
  include Duxml
  include Ox
  def setup
    @g_path = File.expand_path(File.dirname(__FILE__) + '/../../xml/dita_grammar.xml')
    @m = MetaClass.new(g_path)
  end

  attr_reader :m, :g_path

  def test_xml
    x = m.xml
    assert_equal 'meta', x.name
    assert_equal 'grammar', x.nodes[0].name
    assert_equal 'history', x.nodes[1].name
  end

  def test_init_no_grammar
    ng = MetaClass.new
    assert_equal false, ng.grammar.defined?
    ng.grammar = g_path
    assert_equal true, ng.grammar.defined?
    assert_equal 'dita_grammar.xml', File.basename(ng.grammar_path)
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
