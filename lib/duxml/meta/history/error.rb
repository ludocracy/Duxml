# Copyright (c) 2016 Freescale Semiconductor Inc.

require File.expand_path(File.dirname(__FILE__) + '/change')

module Duxml
  module Error
    def error?
      true
    end
  end # class Error

  # do not use except to subclass
  class ErrorClass < ChangeClass
    include Error

    # @param _rule [Rule] rule that was violated
    # @param _change_or_pattern [ChangeClass, PatternClass] can be triggered by a change or a pattern found in a static document
    def initialize(_rule, _change_or_pattern)
      super(_rule)
      @object = _change_or_pattern
    end
    alias_method :rule, :subject
  end

end # module Duxml