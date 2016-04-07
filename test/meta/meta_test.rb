require File.expand_path(File.dirname(__FILE__) + '/../../lib/duxml/meta')
require 'minitest/autorun'

class MetaTest < MiniTest::Test
  attr_reader :meta

  def setup
    sample_template = File.expand_path(File.dirname(__FILE__) + '/../../xml/.design.duxml')
    @meta = Duxml::Meta.new sample_template
  end

  def test_meta_history
    a = meta.history.children.first.type
    assert_equal 'add', a
  end

  def test_meta_grammar
    a = meta.grammar.type
    assert_equal 'grammar', a
  end

  def tear_down
  end
end
