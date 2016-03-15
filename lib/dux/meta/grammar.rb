require File.expand_path(File.dirname(__FILE__) + '/grammar/rule')
require 'rubyXL'

module Dux
  class Grammar < Object
    def initialize xml_node_or_file, args={}
      xml_node = class_to_xml(xml_node_or_file)
      super xml_node, reserved: %w{rule}
    end

    def validate comp
      relationships = {}
      comp.children.each do |child| relationships[child] = :child end
      comp.attributes.each do |k, v| relationships[v] = "attr_name_#{k.to_s}".to_sym end
      relationships[comp.content] = :content
      relationships[comp.parent] = :parent
      relationships.each do |rel, type| qualify Pattern.new(comp, {relationship: type, object: rel}) end
    end

    def qualify change
      children.each do |child|
        subj = change.subject meta
        if subj && child[:subject] == subj.type
          child.qualify change
        end
      end
    end

    private def class_to_xml xml_node_or_file
      if xml_node_or_file.is_a?(String) && File.exists?(xml_node_or_file)
        begin
          worksheet = RubyXL::Parser.parse(xml_node_or_file)[0]
          new_xml = super
          worksheet.each_with_index do |row, index|
            next if index == 0
            break if row[3].nil?
            statement_str = row[4].value.gsub(/[<>]/, '')
            new_xml << element('rule', {subject: row[3].value}, statement_str)
            new_xml << element('rule', {subject: row[3], statement: row[5]}) unless row[5].nil?
          end
          new_xml
        end
      elsif xml_node_or_file.nil?
        super
      else
        xml_node_or_file.xml
      end
    end # def class_to_xml
  end # class Grammar
end # module Dux