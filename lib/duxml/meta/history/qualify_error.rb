require File.expand_path(File.dirname(__FILE__) + '/error')

module Duxml
  module QualifyError; end

  # created when grammar detects error from user input
  class QualifyErrorClass < ErrorClass
    include QualifyError
  end

  module QualifyError
    def description
      super || "#{non_compliant_change.description} violates rule #{violated_rule.description}."
    end

    # points to change that triggered this error
    def non_compliant_change
      root.history.find_child self[:object]
    end
  end # module QualifyError
end # module Duxml