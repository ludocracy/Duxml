require File.expand_path(File.dirname(__FILE__) + '/../../lib/duxml/meta/grammar')
require 'minitest/autorun'
require 'nokogiri/xml/relax_ng'

class RelaxNGTest < MiniTest::Test
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
