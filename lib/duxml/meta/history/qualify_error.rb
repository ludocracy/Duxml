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
      "#{simple_name.gsub('_', ' ')}: #{bad_change.description} violates rule #{rule.description}."
    end
  end # module QualifyError
end # module Duxml