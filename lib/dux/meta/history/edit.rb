require File.expand_path(File.dirname(__FILE__) + '/change')

module Dux
  # do not use; for subclassing
  class Edit < Change; end

  # created when object has no XML children but has text and text has been changed
  class ChangeContent < Edit
    def initialize(*args)
      if class_to_xml *args
        @xml.remove_attribute 'object'
        @xml << args.first[:object]
      end
      super()
    end

    def description
      super
      "#{subject.description} changed content from '#{old_content}' to '#{new_content}'."
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
        args.first[:object].each do |k, v| @xml[k] = v end if args.first[:object].is_a?(Hash)
      end
      super()
    end

    def attr_name
      self[:attr_name]
    end

    def description
      super
      "#{subject.description} changed attribute '#{attr_name}' value from '#{self[:old_value]}' to '#{self[:new_value]}'."
    end
  end

  # created when object had no children or text and text has been added
  class NewContent < Edit
    def description
      super
      "#{subject.description} given new content '#{new_content}'."
    end

    def new_content
      subject.content
    end
  end

  # created when object gains a new attribute
  class NewAttribute < Edit
    # TODO simplify args! currently i believe it's a hash of a hash e.g. args => [{subject: subj, object: {attr_name: attr, old_value: nil, new_value: new_val}}]
    # TODO could simplify to... args => [subj, attr, new_val]
    def initialize(*args)
      if class_to_xml *args
        args.first[:object].each do |k, v| @xml[k] = v end if args.first[:object].is_a?(Hash)
        @xml.remove_attribute 'object'
        @xml.remove_attribute 'old_value'
      end
      super()
    end

    def value(meta)
      subject(meta)[attr_name]
    end

    def attr_name
      self[:attr_name]
    end

    def description
      super
      "#{subject.description} given new attribute '#{self[:attr_name]}' with value '#{self[:new_value]}'."
    end
  end # class NewAttribute
end # module Dux