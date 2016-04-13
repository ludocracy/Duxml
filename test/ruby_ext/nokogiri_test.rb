require_relative '../../lib/duxml/ruby_ext/nokogiri'
require 'minitest/autorun'

class NokogiriTest < MiniTest::Test
  def setup
    # Do nothing
  end

  # Called after every test method runs. Can be used to tear
  # down fixture information.

  def teardown
    # Do nothing
  end

  # Fake test
  def test_element_string
    standard = %(<coop/>).xml.to_s
    assert_equal standard, element('coop').to_s
  end

  def test_nested_elements
    new_xml = element ['coop', %w(butter pecan), 'apple']
    assert_equal 'coop', new_xml.name
    assert_equal 'butter', new_xml.element_children.first.name
    assert_equal 'pecan', new_xml.element_children.first.content
    assert_equal 'apple', new_xml.element_children.first.element_children.first.name
  end

  def test_flexible_new
    new_attr = %(<coop cooper="you"/>).xml.to_s
    new_content = %(<coop>cooper</coop>).xml.to_s
    assert_equal new_attr, element('coop', {cooper: 'you'}).to_s
    assert_equal new_content, element('coop', 'cooper').to_s
  end

  def test_element
    standard = %(<coop a="A" b="B">cooper</coop>).xml.to_s
    assert_equal standard, element('coop', {a: 'A', b: 'B'}, 'cooper').to_s
  end

  def test_element_no_content
    standard = %(<coop a="A" b="B"/>).xml.to_s
    assert_equal standard, element('coop', {a: 'A', b: 'B'}, nil).to_s
  end

  def test_element_no_attrs
    standard = %(<coop>cooper</coop>).xml.to_s
    assert_equal standard, element('coop', nil, 'cooper').to_s
  end
end