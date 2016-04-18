require File.expand_path(File.dirname(__FILE__) + '/../lib/duxml')
require 'test/unit'

class DuxmlTest < Test::Unit::TestCase
  # Called before every test method runs. Can be used
  # to set up fixture information.
  def setup
    @node = Nokogiri::XML(%(<meta><grammar/><history/></meta>))
    @sample_file = File.expand_path(File.dirname(__FILE__) + '/../xml/design.xml')
    @meta_file = File.expand_path(File.dirname(__FILE__) + '/../xml/.design.duxml')
    load sample_file
  end
  attr_reader :node

  def test_save_metadata
    m = Meta.new File.read meta_file
    @current_design << '<temporary/>'
    save
    m = Meta.new File.read meta_file
    assert_equal 'temporary', m.history.first.added(current_meta).type
    @current_design.remove 'temporary'
    assert_equal 'temporary', m.history.first.added(current_meta).type
    save
  end

  def test_line
    target = current_design.find_child 'legal_parent legal_child'
    assert_equal 6, target.line
  end

  # test duxml
  def test_duxml
    # TODO first test that XML::Document has the given methods
    assert_equal 'grammar', node.grammar.name
  end

  # Called after every test method runs. Can be used to tear
  # down fixture information.

  def teardown
    # Do nothing
  end
end