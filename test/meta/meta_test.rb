require File.expand_path(File.dirname(__FILE__) + '/../../lib/duxml')
require 'test/unit'

class MetaTest < Test::Unit::TestCase
  attr_reader :meta

  def setup
    sample_template = File.expand_path(File.dirname(__FILE__) + '/../../xml/.design.duxml')
    @meta = Duxml::Meta.new sample_template
  end

  def test_meta
    # create XML
    Meta.new

    # load from XML
  end

  def test_meta_history
    meta.history.children.first
    assert meta.history.children.first
  end

  def test_meta_grammar
    a = meta.grammar.type
    assert_equal 'grammar', a
  end

  def tear_down
  end
end
