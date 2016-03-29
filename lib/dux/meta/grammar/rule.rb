require File.expand_path(File.dirname(__FILE__) + '/pattern')

module Dux
  class Rule < Pattern
    def qualify change_or_pattern
      type = (change_or_pattern.type == 'pattern') ? :validate_error : :qualify_error
      report type, change_or_pattern
    end

    def description
      %(#{id} which states: #{content})
    end

    def class_to_xml args={}
      xml_node = super
      xml_node[:subject] = args[:subject].to_s
      xml_node << args[:statement]
      xml_node.remove_attribute 'statement'
      xml_node
    end

    private :class_to_xml
  end # class Rule
end # module Dux