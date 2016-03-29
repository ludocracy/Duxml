require File.expand_path(File.dirname(__FILE__) + '/change')

module Dux
  class Error < Change
    def initialize xml_node, args={}
      super xml_node, args
    end

    def violated_rule
      root.grammar.find_child(self[:subject])
    end
  end

  class ValidateError < Error
    def class_to_xml args
      xml_node = super
      xml_node << args[:object].xml
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

  class QualifyError < Error
    def description
      super || "#{non_compliant_change.description} violates rule: #{violated_rule.description}."
    end

    def non_compliant_change
      root.history.find_child self[:object]
    end
  end
end # module Dux