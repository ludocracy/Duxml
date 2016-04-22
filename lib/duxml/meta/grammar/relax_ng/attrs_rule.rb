require File.expand_path(File.dirname(__FILE__) + '/../rule/attrs_rule')
require File.expand_path(File.dirname(__FILE__) + '/../../../doc/lazy_ox')
require 'ox'

module Duxml
  module RngAttrsRule; end

  class AttrsRuleClass
    include RngAttrsRule
  end

  module RngAttrsRule
    include Duxml::LazyOx
    include Ox

    # @param parent [Nokogiri::XML::Node] should be <grammar>
    # @return [Nokogiri::XML::Node] parent, but with additions of <define><attribute> to parent if does not already exist and <ref> to respective <define><doc>
    def relaxng(parent)
      # TODO this is here just to skip generation from namespaced attributes - fix later!!!
      return parent if attr_name.include?(':')
      # TODO

      # if new attribute declaration needed
      unless parent.Define.any? do |d| d.name == attr_name end
        new_def = Element.new('define')
        new_def[:name] = attr_name
        new_attr_def = Element.new('attribute')
        new_attr_def[:name] = attr_name
        new_def << new_attr_def
        parent << new_def
      end

      # update doc with ref, updating previous <optional> if available
      parent.nodes.reverse.each do |define|
        if define.name == subject
          element_def = define.nodes.first
          if requirement == '#REQUIRED'
            cur_element = element_def
          else
            if element_def.nodes.last.name == 'optional'
              cur_element = element_def.nodes.last
            else
              cur_element = Element.new('optional')
              element_def << cur_element
            end
          end # if self[:requirement]=='#REQUIRED'
          new_ref = Element.new('ref')
          new_ref.name = attr_name
          cur_element << new_ref
          break
        end # if define[:name] == subject
      end # parent.element_children.any?
      parent
    end # def relaxng(parent)
  end # module RngAttrsRule
end # module Duxml
