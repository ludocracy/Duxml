require File.expand_path(File.dirname(__FILE__) + '/change')

module Dux
  # do not use
  class Error < Change
    def violated_rule
      root.grammar.find_child(self[:subject])
    end
  end

  # created when grammar detects error from file
  class ValidateError < Error
    def initialize(*args)
      pattern = if class_to_xml *args
        @xml.remove_attribute 'object'
        args.first[:object]
      end
      super()
      self << pattern if pattern
    end

    def affected_parent
      object.subject
    end

    def description
      "#{super} at line #{error_line_no}: #{non_compliant_change.description} which violates rule #{violated_rule.description}."
    end

    def non_compliant_change
      object
    end

    def error_line_no
      object.respond_to?(:line) ? object.line : subject.line
    end
  end

  # created when grammar detects error from user input
  class QualifyError < Error
    def description
      super || "#{non_compliant_change.description} violates rule #{violated_rule.description}."
    end

    def non_compliant_change
      root.history.find_child self[:object]
    end
  end
end # module Dux