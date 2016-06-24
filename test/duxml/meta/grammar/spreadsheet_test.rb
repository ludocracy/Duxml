# Copyright (c) 2016 Freescale Semiconductor Inc.
require File.expand_path(File.dirname(__FILE__) + '/../../../../lib/duxml/meta/grammar')
require 'ox'
require 'test/unit'

class SpreadsheetTest < Test::Unit::TestCase
  include Duxml::Grammar

  def setup

  end

  def test_xlsx2xml_conversion
    xlsx_g = Grammar.import File.expand_path(File.dirname(__FILE__) + '/../../../../xml/Dita 1.3 Manual Spec Conversion.xlsx')
    assert_equal 373, xlsx_g.rules.size
    r = xlsx_g.rules.first
    assert_equal 'duxml:children_rule_class', r.class.to_s.nmtokenize
  end

  def tear_down
  end
end
