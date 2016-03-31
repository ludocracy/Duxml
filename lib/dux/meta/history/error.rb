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
    def class_to_xml *args
      return args.first.xml if args.first.xml
      pattern = args.first[:object].xml
      xml_node = super *args
      xml_node << pattern
      xml_node.remove_attribute 'object'
      xml_node
    end

    def affected_parent
      object.subject
    end

    def description
      super || "#{non_compliant_change.description} violates rule: #{violated_rule.description}."
    end

    def non_compliant_change
      object
    end
  end

  # created when grammar detects error from user input
  class QualifyError < Error
    def description
      super || "#{non_compliant_change.description} violates rule: #{violated_rule.description}."
    end

    def non_compliant_change
      root.history.find_child self[:object]
    end
  end
end # module Dux