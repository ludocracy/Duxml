require File.expand_path(File.dirname(__FILE__) + '/grammar/pattern/child_pattern')
require File.expand_path(File.dirname(__FILE__) + '/grammar/pattern/content_pattern')
require File.expand_path(File.dirname(__FILE__) + '/grammar/pattern/attr_name_pattern')
require File.expand_path(File.dirname(__FILE__) + '/grammar/pattern/attr_val_pattern')
require File.expand_path(File.dirname(__FILE__) + '/grammar/rule/children_rule')
require File.expand_path(File.dirname(__FILE__) + '/grammar/rule/attributes_rule')
require File.expand_path(File.dirname(__FILE__) + '/grammar/rule/value_rule')
require File.expand_path(File.dirname(__FILE__) + '/grammar/rule/content_rule')
require 'rubyXL'

module Dux
  class Grammar < Object
    # applies grammar rules to all relationships of the given object
    def validate(comp)
      if comp.children.any? do |child| !child.text? end
        comp.children.each do |child|
          qualify Dux::ChildPattern.new comp, child
        end
      elsif comp.children.any?
        qualify Dux::ContentPattern.new comp, comp.content
      else
        qualify Dux::ChildPattern.new comp
      end
      comp.attributes.each do |k, v|
        if qualify Dux::AttrNamePattern.new comp, k
          qualify Dux::AttrValPattern.new comp, k
        end
      end
    end # def validate

    def description
      "grammar follows: \n" +
          children.collect do |change_or_error|
            change_or_error.description
          end.join("\n")
    end

    # applies applicable rule type and subject to a given change or pattern and generates errors when disqualified
    def qualify(change_or_pattern)
      get_rules(change_or_pattern.simple_class).each do |child|
        subj = change_or_pattern.subject meta
        subj = subj.type if subj.respond_to?(:type)
        if subj && child[:subject] == subj
          return child.qualify change_or_pattern
        end
      end
    end # def qualify

    def get_rules(type)
      find_children case type
                      when 'new_content', 'change_content', 'content_pattern' then
                        :content_rule
                      when 'new_attribute', 'attr_name_pattern' then
                        :attributes_rule
                      when 'change_attribute', 'attr_val_pattern' then
                        :value_rule
                      when 'add', 'remove', 'child_pattern' then
                        :children_rule
                      else # should not happen
                    end
    end

    private

    def initialize(xml_node_or_file=nil)
      if xml_node_or_file.is_a?(String) && File.exists?(xml_node_or_file)
        worksheet = RubyXL::Parser.parse(xml_node_or_file)[0]
        rule_hash = {}
        worksheet.each_with_index do |row, index|
          next if index == 0
          break if row[3].nil? || row[4].nil?
          element_name = row[3].value
          statement_str = row[4].value
          rule_hash[element_name+statement_str] = Dux::ChildrenRule.new(element_name, statement_str)
          row_five = row[5].value.split(/\n/)
          row[5].value.split(/\n/).each do |rule|
            next if rule.empty?
            attr_name, attr_val, attr_req = *rule.split
            rule_hash[element_name] ||= Dux::AttributesRule.new(element_name, attr_name, attr_req)
            rule_hash[attr_name] ||= Dux::ValueRule.new(element_name, attr_name, attr_val)
          end
        end # worksheet.each_with_index
        class_to_xml nil
        rule_hash.each do |k, v|
          @xml << v.xml
        end
      else
        class_to_xml xml_node_or_file
      end # if...else xml_node_or_file is an .xslx file or similar spreadsheet
      super xml[:ref] || xml
    end # def class_to_xml
  end # class Grammar
end # module Dux