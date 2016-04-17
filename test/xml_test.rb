require File.expand_path(File.dirname(__FILE__) + '/../lib/duxml/xml')
require 'test/unit'

module Maudule
  class Klass
    attr_reader :name, :children

    def initialize(_name)
      @name = _name
      @children = []
    end

    def <<(obj)
      @children << obj
    end

    def each(&block)
      @children.each(&block)
    end
  end
end

class XMLTest < Test::Unit::TestCase
  include Duxml::XML
  # Called before every test method runs. Can be used
  # to set up fixture information.
  def setup
  end


  def test_xml
    k = Maudule::Klass.new('primus')
    k << Maudule::Klass.new('secundus')
    k << Maudule::Klass.new('tertius')
    x = xml(k)
    assert_equal %(<maudule:klass name="primus"><maudule:klass name="secundus"/><maudule:klass name="tertius"/></maudule:klass>), Ox.dump(x, indent: -1).gsub(/\n/,'')
  end

  # Called after every test method runs. Can be used to tear
  # down fixture information.

  def teardown
    # Do nothing
  end
end