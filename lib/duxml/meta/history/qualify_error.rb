# Copyright (c) 2016 Freescale Semiconductor Inc.

require File.expand_path(File.dirname(__FILE__) + '/error')

module Duxml
  module QualifyError; end

  # created when grammar detects error from user input
  class QualifyErrorClass < ErrorClass
    include QualifyError

    alias_method :bad_change, :object
  end

  module QualifyError

    def description
      rule_str = rule.respond_to?(:validate) ? 'not allowed by this Grammar' : "violates #{rule.description}"
      "Qualify Error #{super} #{bad_change.description} #{rule_str}."
    end
  end # module QualifyError
end # module Duxml