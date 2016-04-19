require File.expand_path(File.dirname(__FILE__) + '/../../lib/duxml/ox_ext/ox')
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
  end
end

class OxTest < Test::Unit::TestCase
  include Ox
  # Called before every test method runs. Can be used
  # to set up fixture information.
  def setup
  end

  def test_line_counter
    path = File.expand_path(File.dirname(__FILE__) + '/../../xml/design.xml')
    file = File.open path
    doc = sax file
    assert_equal 2, doc.design.line
    assert_equal 4, doc.design.legal_parent.also_legal_child.line
    assert_equal 6, doc.design.legal_parent.legal_child.line
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