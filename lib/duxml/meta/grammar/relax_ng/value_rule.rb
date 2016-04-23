require File.expand_path(File.dirname(__FILE__) + '/../rule/value_rule')

module Duxml
  module RngValueRule; end

  class ValueRuleClass
    include RngValueRule
  end

  module RngValueRule
    include Duxml::LazyOx
    # @param parent [Nokogiri::XML::Node] <grammar> i.e. parent node in RelaxNG document, NOT this Rule's document
    # @return [Nokogiri::XML::Node] parent, but adds to corresponding <define><attribute> a child <data type="#{statement}">
    #   where #statement can be 'CDATA', 'NMTOKEN', etc.
    def relaxng(parent)
      parent.Define.each do |define|
        if define[:name] == attr_name
          attr_def = define.nodes.first
          unless attr_def.nodes.any?
            data_type = statement == 'CDATA' ? 'string' : statement
            if data_type.include?('|')
              choice_node = Element.new('choice')
              attr_def << choice_node
              data_type.split(/[\(\|\)]/).each do |en_val|
                if Regexp.nmtoken.match(en_val)
                  value_def = Element.new('value')
                  value_def << en_val
                  choice_node << value_def
                end
              end
            else
              data_def = Element.new('data')
              data_def[:type] = data_type
              attr_def << data_def
            end
          end # unless attr_def.nodes.any?
          return parent
        end # if define[:name] == attr_name
      end # parent.nodes.each
    end # def relaxng
  end # module RngValuesRule
end # module Duxml
