require File.expand_path(File.dirname(__FILE__) + '/../../lib/duxml/ruby_ext/regexp')
require 'test/unit'

class RegexpText < Test::Unit::TestCase
  def setup

  end

  def test_regexp_constant
    %w(CONSTANT Constant ConStant Con_stant).each do |s|
      assert_equal s, Regexp.constant.match(s).to_s
    end

    ['constant', 'cONSTANT', 'Con stant', 'Con-stant'].each do |s|
      assert_not_equal s, Regexp.constant.match(s).to_s
    end
  end

  def test_regexp_identifier
    %w(identifier Identifier identifier0 identifier_0 _identifier).each do |s|
      assert_equal s, Regexp.identifier.match(s).to_s
    end

    ['ident ifier', '0identifier', 'ident-ifier', 'identi.fier', 'identi:fier'].each do |s|
      assert_not_equal s, Regexp.identifier.match(s).to_s
    end
  end

  def test_regexp_nmtoken
    %w(identifier Identifier identifier0 :identifier identi.fier identifier_0 _identifier ident-ifier identi:fier ).each do |s|
      assert_equal s, Regexp.nmtoken.match(s).to_s
    end

    ['ident ifier', '0identifier'].each do |s|
      assert_not_equal s, Regexp.nmtoken.match(s).to_s
    end
  end

  def tear_down

  end

end # end of RewriterTest
