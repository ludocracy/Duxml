require File.expand_path(File.dirname(__FILE__) + '/../lib/dux')
require 'minitest/autorun'

class DuxTest < MiniTest::Test
  include Dux

  def setup
    sample_dux = File.expand_path(File.dirname(__FILE__) + '/../xml/design.xml')
    load sample_dux
    schema_rule = Rule.new element 'rule', {subject: 'legal_parent'}, '%w(legal_child).include? object.type'
    content_rule = Rule.new element 'rule', {subject: 'target'}, %(subject.content != 'something something')
    current_dux.grammar << content_rule
    current_dux.grammar << schema_rule
  end

  def test_grammar_validate
    validate
    assert_equal 'validate_error', current_dux.history.first.type
    assert_equal 'validate_error', current_dux.history[1].type
  end

  def tear_down
  end
end
