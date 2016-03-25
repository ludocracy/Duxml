require File.expand_path(File.dirname(__FILE__) + '/pattern')

module Dux
  class Rule < Pattern
    def qualify change_or_pattern
      subject = change_or_pattern.subject meta
      object = (change_or_pattern[:object] == :nil) ? nil : change_or_pattern.object(meta)

      begin
        # TODO use a safer eval - filter? use limited eval?
        # one statement only
        # no objects but components or object arguments
        # no methods but object interface or sub interfaces
        qualified_or_false = eval content, get_binding(object)
      end

      type = (change_or_pattern.type == 'pattern') ? :validate_error : :qualify_error

      report type, change_or_pattern unless qualified_or_false || qualified_or_false.nil?
      qualified_or_false
    end

    def description
      %(#{id} of type #{type} which states: #{content})
    end

    def class_to_xml args={}
      xml_node = super
      xml_node[:subject] = args[:subject].to_s
      xml_node << args[:statement]
      xml_node.remove_attribute 'statement'
      xml_node
    end

    def get_binding object
      binding
    end

    private :class_to_xml
  end # class Rule
end # module Dux