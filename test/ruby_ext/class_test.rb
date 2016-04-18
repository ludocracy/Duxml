require File.expand_path(File.dirname(__FILE__) + '/../../lib/duxml/ruby_ext/class')
require 'test/unit'

module Maudule
  class Klass; end
end

class ClassTest < Test::Unit::TestCase
  def setup
  end

  # Called after every test method runs. Can be used to tear
  # down fixture information.

  def teardown
    # Do nothing
  end

  def test_simple_module
    assert_equal "Maudule", Maudule::Klass.simple_module
    assert_equal "Module", String.simple_module
  end

  def test_simple_class
    assert_equal 'Klass', Maudule::Klass.simple_class
  end
end