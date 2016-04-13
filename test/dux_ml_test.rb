require File.expand_path(File.dirname(__FILE__) + '/../lib/duxml')
require 'minitest/autorun'

class DuxMlTest < MiniTest::Test
  include Duxml

  attr_accessor :sample_file, :meta_file

  def setup
    @sample_file = File.expand_path(File.dirname(__FILE__) + '/../xml/design.xml')
    @meta_file = File.expand_path(File.dirname(__FILE__) + '/../xml/.design.duxml')
    load sample_file
  end

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

  def tear_down

  end
end
