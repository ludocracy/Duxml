require File.expand_path(File.dirname(__FILE__) + '/../lib/duxml')
require 'test/unit'

class RelaxNGTest < Test::Unit::TestCase
include Duxml

  def test_relaxng
    test_grammar = Grammar.new File.expand_path(File.dirname(__FILE__) + '/../../xml/test_grammar.xml')
    rng = test_grammar.relaxng 'test.rng'
    assert Nokogiri::XML::RelaxNG.new rng.to_xml
  end

  def tear_down
    File.close 'test.rng'
    File.delete 'test.rng'
  end
end
