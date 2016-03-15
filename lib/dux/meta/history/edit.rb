require File.expand_path(File.dirname(__FILE__) + '/change')

module Dux
  class Edit < Change
    def description
      super if super
    end
  end

  class ChangeContent < Edit
    private def class_to_xml args={}
      xml_node = super
      xml_node.content = args[:object].to_s
      xml_node
    end

    def description
      super
      "Element '#{subject.id}' of type '#{subject.type}' changed content from '#{old_content}' to '#{new_content}'."
    end

    def old_content
      content
    end

    def new_content
      subject.content
    end
  end

  class ChangeAttribute < Edit
    private def class_to_xml args={}
      xml_node = super args
      args[:object].each do |k, v| xml_node[k] = v end if args[:object].is_a?(Hash)
      xml_node
    end

    def description
      super
      "Element '#{subject.id}' of type '#{subject.type}' changed attribute '#{self[:attr_name]}' value from '#{self[:old_value]}' to '#{self[:new_value]}'."
    end
  end

  class NewContent < Edit
    def description
      super
      "Element '#{subject.id}' of type '#{subject.type}' given new content '#{new_content}'."
    end

    def new_content
      subject.content
    end
  end

  class NewAttribute < Edit
    private def class_to_xml args={}
      xml_node = super args
      args[:object].each do |k, v| xml_node[k] = v end if args[:object].is_a?(Hash)
      xml_node
    end

    def description
      super
      "Element '#{subject.id}' of type '#{subject.type}' given new attribute '#{self[:attr_name]}' with value '#{self[:new_value]}'."
    end
  end
end # module Dux