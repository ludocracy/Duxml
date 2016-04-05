require File.expand_path(File.dirname(__FILE__) + '/change')

module Dux
  # do not use
  class Edit < Change; end

  # created when object has no XML children but has text and text has been changed
  class ChangeContent < Edit
    def initialize(*args)
      if class_to_xml *args
        @xml_root_node.remove_attribute 'object'
        @xml_root_node << args.first[:object]
      end
      super xml_root_node
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
  end # class ChangeContent

  # created when object has a given attribute and its value has been changed
  class ChangeAttribute < Edit
    def initialize(*args)
      if class_to_xml *args
        args.first[:object].each do |k, v| @xml_root_node[k] = v end if args.first[:object].is_a?(Hash)
      end
      super xml_root_node
    end

    def description
      super
      "Element '#{subject.id}' of type '#{subject.type}' changed attribute '#{self[:attr_name]}' value from '#{self[:old_value]}' to '#{self[:new_value]}'."
    end
  end

  # created when object had no children or text and text has been added
  class NewContent < Edit
    def description
      super
      "Element '#{subject.id}' of type '#{subject.type}' given new content '#{new_content}'."
    end

    def new_content
      subject.content
    end
  end

  # created when object gains a new attribute
  class NewAttribute < Edit
    #
    def initialize(*args)
      if class_to_xml *args
        args.first[:object].each do |k, v| @xml_root_node[k] = v end if args.first[:object].is_a?(Hash)
      end
      super xml_root_node
    end

    def description
      super
      "Element '#{subject.id}' of type '#{subject.type}' given new attribute '#{self[:attr_name]}' with value '#{self[:new_value]}'."
    end
  end # class NewAttribute
end # module Dux