require File.expand_path(File.dirname(__FILE__) + '/../../lib/duxml/meta')
require 'test/unit'

class MetaTest < Test::Unit::TestCase
  include Duxml
  include Ox
  def setup

  end

  def test
    assert_equal %(<meta><grammar/><history/></meta>), dump(xml(Meta))
  end

  def tear_down
  end
end
