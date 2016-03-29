require File.expand_path(File.dirname(__FILE__) + '/grammar/rule/child_rule')
require File.expand_path(File.dirname(__FILE__) + '/grammar/rule/attr_rule')
require File.expand_path(File.dirname(__FILE__) + '/grammar/rule/content_rule')
require 'rubyXL'

module Dux
  class Grammar < Object
    def initialize xml_node_or_file, args={}
      xml_node = class_to_xml(xml_node_or_file)
      xml_node = xml_node[:ref] ? class_to_xml(xml_node[:ref]) : xml_node
      super xml_node
    end

    def class_to_xml xml_node_or_file
      if xml_node_or_file.is_a?(String) && File.exists?(xml_node_or_file)
        worksheet = RubyXL::Parser.parse(xml_node_or_file)[0]
        new_xml = super
        worksheet.each_with_index do |row, index|
          next if index == 0
          break if row[3].nil? || row[4].nil?
          statement_str = row[4].value
          new_xml << element('child_rule', {subject: row[3].value, statement: statement_str})
          #new_xml << element('regexp_rule', {subject: row[3], statement: row[5].value}) unless row[5].nil?
        end
        new_xml
      elsif xml_node_or_file.nil?
        super
      else
        xml_node_or_file.xml
      end
    end # def class_to_xml

    def validate comp
      relationships = {}
      if comp.children.any?
        comp.children.each do |child| relationships[child] = :child end
      else
        relationships[:nil] = :child
      end
      #comp.attributes.each do |k, v| relationships[v] = "attr_name_#{k.to_s}".to_sym end
      #relationships[comp.content] = :content
      relationships.each do |relation, type|
        qualify Pattern.new(comp, {relationship: type, object: relation})
      end
    end

    def description
      "grammar follows: \n" +
          children.collect do |change_or_error|
            change_or_error.description
          end.join("\n")
    end

    def qualify change
      children.each do |child|
        subj = change.subject meta
        if subj && child[:subject] == subj.type
          child.qualify change
        end
      end
    end
  end # class Grammar
end # module Dux