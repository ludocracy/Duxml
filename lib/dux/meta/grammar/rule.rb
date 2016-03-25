require File.expand_path(File.dirname(__FILE__) + '/pattern')

module Dux
  class Rule < Pattern
    def qualify change
      subject = change.subject meta
      object = (change[:object] == :nil) ? nil : change.object(meta)

      begin
        # TODO use a safer eval - filter? use limited eval?
        # one statement only
        # no objects but components or object arguments
        # no methods but object interface or sub interfaces
        qualified_or_false = eval content, get_binding(object)
      end

      if change.type == 'pattern'
        type = :validate_error
        target = subject
      else
        type = :qualify_error
        target = change
      end

      report type, target unless qualified_or_false || qualified_or_false.nil?
      qualified_or_false
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