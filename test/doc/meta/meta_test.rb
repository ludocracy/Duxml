require File.expand_path(File.dirname(__FILE__) + '/../../../lib/duxml/doc/meta')
require 'test/unit'

class MetaTest < Test::Unit::TestCase
  include Duxml
  include Ox
  def setup

  end

  def test
    x = Meta.xml
    assert_equal 'duxml:meta', x.name
    assert_equal 'duxml:grammar', x.nodes.first.name
    assert_equal 'duxml:history', x.nodes.last.name
  end

  def tear_down
  end
end
