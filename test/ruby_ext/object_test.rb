require_relative '../../lib/duxml/ruby_ext/object'
require 'test/unit'

module Maudule
  class Klass; end
end

class ObjectTest < Test::Unit::TestCase
  def setup
  end

  # Called after every test method runs. Can be used to tear
  # down fixture information.

  def teardown
    # Do nothing
  end

  def test_simple_module
    assert_equal 'Maudule', Maudule::Klass.new.simple_module
  end

  def test_simple_class
    assert_equal 'Klass', Maudule::Klass.new.simple_class
  end
end