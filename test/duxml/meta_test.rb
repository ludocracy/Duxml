require File.expand_path(File.dirname(__FILE__) + '/../../lib/duxml/meta')
require 'test/unit'

class MetaTest < Test::Unit::TestCase
  include Duxml
  include Ox
  def setup
    @x = Meta.xml
  end

  attr_reader :x

  def test_xml
    assert_equal 'duxml:meta', x.name
    assert_equal 'duxml:grammar', x.nodes.first.name
    assert_equal 'duxml:history', x.nodes.last.name
  end

  def test_update
    assert_equal true, x.nodes.first.respond_to?(:update)
    assert_equal true, x.nodes.last.respond_to?(:update)
  end

  def tear_down
  end
end
