# Copyright (c) 2016 Freescale Semiconductor Inc.

require File.expand_path(File.dirname(__FILE__) + '/error')

module Duxml
  module ValidateError; end

  # created when grammar detects error from file
  class ValidateErrorClass < ErrorClass
    include ValidateError

    alias_method :bad_pattern, :object
  end

  module ValidateError
    def description
      rule_str = rule.respond_to?(:validate) ? 'not allowed by this Grammar' : "violates #{rule.description}"
      "Validate Error #{super} #{bad_pattern.description} #{rule_str}."
    end
  end # module ValidateError
end # module Duxml