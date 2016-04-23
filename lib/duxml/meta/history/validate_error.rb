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
      "#{simple_name.gsub('_', ' ')} at line #{error_line_no}: #{bad_pattern.description} which violates rule #{rule.description}."
    end

    # returns XML file line number of error causing object (or subject if no object exists)
    def error_line_no
      bad_pattern.object.respond_to?(:line) ? bad_pattern.object.line : bad_pattern.subject.line
    end
  end # module ValidateError
end # module Duxml