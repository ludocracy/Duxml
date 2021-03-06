# Copyright (c) 2016 Freescale Semiconductor Inc.

require File.expand_path(File.dirname(__FILE__) + '/../../lib/duxml/saxer')
require 'test/unit'

class Observer
  def update(*_args)
    @args = _args
  end
  attr_reader :args
end

class DocTest < Test::Unit::TestCase
  include Duxml
  include Saxer
  # Called before every test method runs. Can be used
  # to set up fixture information.
  def setup
    @x = Doc.new
  end

attr_reader :x

  def test_to_s
    x << Element.new('design')
    assert_equal "@root='<design>'>", x.to_s[-17..-1]
  end

  def test_node_set
    assert_kind_of NodeSet, x.nodes
  end

  def test_path
    assert_nil x.path
    x.path = 'file.xml'
    assert_equal 'file.xml', x.path
    assert File.exists? x.path
    assert File.exists? Meta.meta_path x.path
  end

  def test_meta
    assert_kind_of MetaClass, x.meta
  end

  def test_set_meta
    m = MetaClass.new
    d = x.set_meta(m)
    assert_same m, x.meta
    assert_same x, d
  end

  def test_history
    assert_kind_of HistoryClass, x.history
    x << Element.new('root')
    assert_equal '<root> added to document at index 0.', x.history[0].description[30..-1]
  end

  def test_grammar
    assert_equal 0, x.grammar.rules.size
  end

  def test_assign_grammar
    x.grammar = GrammarClass.new
    assert_kind_of GrammarClass, x.grammar
  end

  def test_find_by_id
    path = File.expand_path(File.dirname(__FILE__) + '/../../xml/design.xml')
    doc = sax path
    target = doc.find_by_id('legal_child0')
    assert_same target, doc.root.legal_parent.legal_child
  end

  # Called after every test method runs. Can be used to tear
  # down fixture information.

  def teardown
    File.delete 'file.xml' if File.exists?('file.xml')
    File.delete '.file.xml.duxml' if File.exists?('.file.xml.duxml')
  end
end