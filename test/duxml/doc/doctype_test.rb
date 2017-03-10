# Copyright (c) 2016 Freescale Semiconductor Inc.
require File.expand_path(File.dirname(__FILE__) + '/../../../lib/duxml/doc/element')
require File.expand_path(File.dirname(__FILE__) + '/../../../lib/duxml/doc')
require 'test/unit'

class Observer
  def update(*_args)
    @args = _args
  end
  attr_reader :args
end

class DocTypeTest < MiniTest::Unit::TestCase
  include Duxml

  def setup
    @t = DocTypeT.new('doctype PUBLIC PATH string')
    @m = Doc.new(version: '1.0', encoding: 'UTF-8', standalone: 'no')
    @o = Observer.new
  end

  attr_accessor :t, :o, :m

  def test_doctype
    assert_equal 'doctype PUBLIC PATH string', @t.value
  end

  def test_doctype_to_s
    assert_equal "<!DOCTYPE doctype PUBLIC PATH string>\n", @t.to_s
  end
  
  def test_doc_w_doctype
    assert_nil @m.doc_type
    @m.doctype = @t
    assert_equal @m.doc_type, @t
    assert_equal "<!DOCTYPE doctype PUBLIC PATH string>\n", @m.doc_type.to_s
  end
  
  def tear_down
  end
end
