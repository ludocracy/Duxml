require File.expand_path(File.dirname(__FILE__) + '/../../../../lib/duxml/meta/history/validate_error')
require 'test/unit'

class Observer
  def update(*_args)
    @args = _args
  end
  attr_reader :args
end

class ValidateErrorTest < Test::Unit::TestCase
  def setup
  end

  def test_init_child_rule
  end

  def tear_down
  end
end
