require File.expand_path(File.dirname(__FILE__) + '/../../../../../lib/duxml/meta/grammar')
require 'test/unit'
require 'nokogiri/xml/relax_ng'

class RelaxNGTest < Test::Unit::TestCase
  include Duxml
  include Nokogiri

  def test_relaxng
    test_grammar = Grammar.import File.expand_path(File.dirname(__FILE__) + '/../../../../../xml/test_grammar.xml')
    rng = test_grammar.relaxng 'test.rng'
    s = rng.to_s
    assert Nokogiri::XML::RelaxNG.new s
  end

  def tear_down
    File.close 'test.rng'
    File.delete 'test.rng'
  end
end
