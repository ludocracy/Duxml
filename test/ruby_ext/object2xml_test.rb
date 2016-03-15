require_relative '../../lib/dux/ruby_ext/object'
require 'minitest/autorun'

class MooMoo; end

class Object2XMLTest < MiniTest::Test
  def setup
  end

  # Called after every test method runs. Can be used to tear
  # down fixture information.

  def teardown
    # Do nothing
  end

  def test_file_str_to_xml
    sample_file_path = File.expand_path(File.dirname(__FILE__) + '/../../xml/design.xml')
    assert sample_file_path.xml
  end


  def test_nil_xml
    assert "".xml.nil?
    assert nil.xml.nil?
  end

  def test_class_to_str
    assert_equal 'moo_moo', MooMoo.new.simple_class
  end

  def test_string_to_xml
    assert "<poop/>".xml
    assert "<poop></poop>"
    assert "<pooper>poop</pooper>"
  end

  def test_get_xml
    assert "<poop>".xml.is_a?(Nokogiri::XML::Element)
  end
end