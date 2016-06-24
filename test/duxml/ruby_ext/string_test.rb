# Copyright (c) 2016 Freescale Semiconductor Inc.
require File.expand_path(File.dirname(__FILE__) + '/../../../lib/duxml/ruby_ext/string')
require 'test/unit'

class StringTest < Test::Unit::TestCase
  def setup
    # Do nothing
  end

  # Called after every test method runs. Can be used to tear
  # down fixture information.

  def teardown
    # Do nothing
  end

  def test_constantize_and_back
    assert_equal 'MailMan', 'mail_man'.constantize
    assert_equal 'mail_man', 'mail_man'.constantize.nmtokenize
    assert_equal 'Mail_man', 'mail-man'.constantize
    assert_equal 'mail-man', 'mail-man'.constantize.nmtokenize
    assert_equal 'MailMan', 'MailMan'.constantize
  end
end