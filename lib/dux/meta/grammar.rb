require File.expand_path(File.dirname(__FILE__) + '/grammar/pattern/child_pattern')
require File.expand_path(File.dirname(__FILE__) + '/grammar/pattern/content_pattern')
require File.expand_path(File.dirname(__FILE__) + '/grammar/pattern/attr_name_pattern')
require File.expand_path(File.dirname(__FILE__) + '/grammar/pattern/attr_val_pattern')
require File.expand_path(File.dirname(__FILE__) + '/grammar/rule/child_rule')
require File.expand_path(File.dirname(__FILE__) + '/grammar/rule/attr_name_rule')
require File.expand_path(File.dirname(__FILE__) + '/grammar/rule/attr_val_rule')
require File.expand_path(File.dirname(__FILE__) + '/grammar/rule/content_rule')
require 'rubyXL'

module Dux
  class Grammar < Object
    def initialize(xml_node_or_file=nil)
      xml_node = class_to_xml(xml_node_or_file)
      xml_node = xml_node[:ref] ? class_to_xml(xml_node[:ref]) : xml_node
      super xml_node
    end

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
        qualify Dux::AttrNamePattern.new comp, k
        qualify Dux::AttrValPattern.new k, v
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
        if subj && child[:subject] == subj.type
          child.qualify change_or_pattern
        end
      end
    end # def qualify

    def get_rules(type)
      find_children case type
                      when 'new_content', 'change_content', 'content_pattern' then
                        :content_rule
                      when 'new_attribute', 'attr_name_pattern' then
                        :attr_name_rule
                      when 'change_attribute', 'attr_val_pattern' then
                        :attr_val_rule
                      when 'add', 'remove', 'child_pattern' then
                        :child_rule
                      else # should not happen
                    end
    end

    private

    def class_to_xml(xml_node_or_file)
      if xml_node_or_file.is_a?(String) && File.exists?(xml_node_or_file)
        worksheet = RubyXL::Parser.parse(xml_node_or_file)[0]
        new_xml = super
        worksheet.each_with_index do |row, index|
          next if index == 0
          break if row[3].nil? || row[4].nil?
          statement_str = row[4].value
          new_xml << Dux::ChildRule.new(row[3].value, statement_str).xml
          #new_xml << element('regexp_rule', {subject: row[3], statement: row[5].value}) unless row[5].nil?
        end
        new_xml[:id] = new_id
        new_xml
      else
        super xml_node_or_file
      end # if...else xml_node_or_file is an .xslx file or similar spreadsheet
    end # def class_to_xml
  end # class Grammar
end # module Dux