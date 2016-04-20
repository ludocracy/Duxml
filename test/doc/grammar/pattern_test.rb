require File.expand_path(File.dirname(__FILE__) + '/../../../lib/duxml/doc/grammar/pattern')
require 'test/unit'

module Maudule
  class EgPattern
    include Duxml::Pattern
    def initialize(*args)
      @subject = args.first
      @eg = args.last
    end

    def parent
      true
    end
  end

  class NullPattern
    include Duxml::Pattern
    def initialize(_subject); @subject = _subject end
    attr_reader :subject
  end
end

class PatternTest < Test::Unit::TestCase
  include Duxml

  def setup
    @p = Maudule::EgPattern.new(Element.new('primus'), Element.new('egus'))
  end

  attr_reader :p

  def test_nil_object
    assert_equal nil, Maudule::NullPattern.new(p).object
    assert_equal nil, Maudule::EgPattern.new(p, nil).object
  end

  def test_name
    assert_equal 'maudule:eg_pattern', p.name
  end

  def test_simple_name
    assert_equal 'eg_pattern', p.simple_name
  end

  def test_subject
    assert_equal 'primus', p.subject.name
  end

  def test_relationship
    assert_equal 'eg', p.relationship
  end

  def test_object
    assert_equal 'egus', p.object.name
  end

  def test_compare
    #TODO finish this test when we better understand Ox::Element#<=>
  end

  def tear_down
  end
end
