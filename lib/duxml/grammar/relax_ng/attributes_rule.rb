require File.expand_path(File.dirname(__FILE__) + '/../rule/attributes_rule.rb')

module Duxml
  AttributesRule.class_eval do
    # @param parent [Nokogiri::XML::Node] should be <grammar>
    # @return [Nokogiri::XML::Node] parent, but with additions of <define><attribute> to parent if does not already exist and <ref> to respective <define><element>
    def relaxng(parent)
      # TODO this is here just to skip generation from namespaced attributes - fix later!!!
      return parent if attr_name.include?(':')
      # TODO

      # if new attribute declaration needed
      unless parent.element_children.any? do |attr_def|
        attr_def[:name] == attr_name
      end
        parent << element('define', {name: attr_name}, element('attribute', name: attr_name))
      end

      # update element with ref, updating previous <optional> if available
      parent.element_children.reverse.each do |define|
        if define[:name] == subject
          element_def = define.element_children.first
          if self[:requirement]=='#REQUIRED'
            cur_element = element_def
          else
            if element_def.element_children.last.name == 'optional'
              cur_element = element_def.element_children.last
            else
              cur_element = element 'optional'
              element_def << cur_element
            end
          end # if self[:requirement]=='#REQUIRED'
          cur_element << element('ref', name: attr_name)
          break
        end # if define[:name] == subject
      end # parent.element_children.any?
      parent
  end
  end
end
