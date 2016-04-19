require File.expand_path(File.dirname(__FILE__) + '/../rule/value_rule.rb')

module Duxml
  ValueRule.class_eval do
    # @param parent [Nokogiri::XML::Node] <grammar> i.e. parent node in RelaxNG document, NOT this Rule's document
    # @return [Nokogiri::XML::Node] parent, but adds to corresponding <define><attribute> a child <data type="#{statement}">
    #   where #statement can be 'CDATA', 'NMTOKEN', etc.
    def relaxng(parent)
      parent.element_children.each do |define|
        if define[:name] == attr_name
          attr_def = define.element_children.first
          unless attr_def.element_children.any?
            data_type = statement == 'CDATA' ? 'string' : statement
            if data_type.include?('|')
              choice_node = element('choice')
              attr_def << choice_node
              data_type.split(/[\(\|\)]/).each do |en_val|
                choice_node << element('value', en_val) if Regexp.nmtoken.match(en_val)
              end
            else
              attr_def << element('data', type: data_type)
            end
          end # unless attr_def.element_children.any?
          return parent
        end # if define[:name] == attr_name
      end # parent.element_children.each
    end # def relaxng
  end # ValuesRule.class_eval
end # module Duxml
