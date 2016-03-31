require_relative '../../lib/dux/ruby_ext/regexp'
require 'minitest/autorun'

# test term formatting - without regard to validity of evaluation
class RegexpIdentifierTest < MiniTest::Test
  def setup

  end

  def test_regexp_identifier
    assert_equal "var", ("var ? true : false").match(Regexp.identifier).to_s
  end

  def tear_down

  end

end # end of RewriterTest