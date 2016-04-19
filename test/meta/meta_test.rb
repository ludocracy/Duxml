require File.expand_path(File.dirname(__FILE__) + '/../../lib/duxml/meta')
require 'test/unit'

class MetaTest < Test::Unit::TestCase
  include Duxml
  include Ox
  def setup

  end

  def test
    x = xml(Meta)
    assert_equal 'meta', x.name
    assert_equal 'grammar', x.grammar.name
    assert_equal 'history', x.history.name
  end

  def tear_down
  end
end
