require File.expand_path(File.dirname(__FILE__) + '/../../../lib/duxml/ruby_ext/fixnum')
require 'test/unit'

class FixnumText < Test::Unit::TestCase
  def setup

  end

  def test_ordinal
    assert_equal '1st', 1.ordinal
    assert_equal '42nd', 42.ordinal
    assert_equal '10003rd', 10003.ordinal
    assert_equal '208th', 208.ordinal
  end

  def test_suffix
    assert_equal 'st', 1.suffix
    assert_equal 'nd', 2.suffix
    assert_equal 'rd', 3.suffix
    assert_equal 'th', 4.suffix
    assert_equal 'nd', 452.suffix
    assert_equal 'th', 200009.suffix
  end

  def test_to_word
    assert_equal 'twenty', 20.to_word
    assert_equal 'eighty', 80.to_word
    assert_equal 'eighty-one', 81.to_word
    assert_equal 'four hundred and fifty-two', 452.to_word
    assert_equal 'nine thousand eight hundred and three', 9803.to_word
    assert_equal 'twenty thousand', 20000.to_word
    assert_equal 'twenty thousand and nineteen', 20019.to_word
    assert_equal 'six hundred and twelve thousand and four', 612004.to_word
    assert_equal 'six hundred and twelve million four thousand and twenty-one', 612004021.to_word
  end

  def test_ordinal_name
    assert_equal 'first', 1.ordinal_name
    assert_equal 'ninth', 9.ordinal_name
    assert_equal 'tenth', 10.ordinal_name
    assert_equal 'eleventh', 11.ordinal_name
    assert_equal 'twelfth', 12.ordinal_name
    assert_equal 'thirteenth', 13.ordinal_name
    assert_equal 'eighty-first', 81.ordinal_name
    assert_equal 'four hundred and fifty-second', 452.ordinal_name
    assert_equal 'nine thousand eight hundred and third', 9803.ordinal_name
    assert_equal 'twenty thousand and nineteenth', 20019.ordinal_name
    assert_equal 'six hundred and twelve thousand and fourth', 612004.ordinal_name
  end

  def tear_down

  end

end # end of RewriterTest
