require File.expand_path(File.dirname(__FILE__) + '/grammar/rule')
require 'rubyXL'

module Dux
  class Grammar < Object
    def initialize xml_node_or_file, args={}
      xml_node = class_to_xml(xml_node_or_file)
      xml_node = xml_node[:ref] ? class_to_xml(xml_node[:ref]) : xml_node
      super xml_node, reserved: %w{rule}
    end

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