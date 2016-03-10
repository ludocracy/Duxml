require File.expand_path(File.dirname(__FILE__) + '/grammar/rule')

module Dux
  class Grammar < Object
    def initialize xml_node, args={}
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
  end # class Grammar
end # module Dux