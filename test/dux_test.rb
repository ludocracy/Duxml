require File.expand_path(File.dirname(__FILE__) + '/../lib/dux')
require 'minitest/autorun'

class DuxTest < MiniTest::Test
  include Dux

  def setup
    sample_dux = File.expand_path(File.dirname(__FILE__) + '/../xml/design.xml')
    load sample_dux
  end

  def test_grammar_validate
    validate
    assert_equal 'add', current_dux.history.first.type
  end

  def tear_down
  end
end
