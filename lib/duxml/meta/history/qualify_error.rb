require File.expand_path(File.dirname(__FILE__) + '/error')

module Duxml
  # created when grammar detects error from user input
  class QualifyError < Error
    def description
      super || "#{non_compliant_change.description} violates rule #{violated_rule.description}."
    end

    # points to change that triggered this error
    def non_compliant_change
      root.history.find_child self[:object]
    end
  end # class QualifyError
end # module Duxml