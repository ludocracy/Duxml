require File.expand_path(File.dirname(__FILE__) + '/edit')

module Duxml
  # created when object has a given attribute and its value has been changed
  class ChangeAttribute < Edit
    def initialize(*args)
      if class_to_xml *args
        args.first[:object].each do |k, v| @xml[k] = v end if args.first[:object].is_a?(Hash)
      end
      super()
    end

    # name of the attribute that was changed
    def attr_name
      self[:attr_name]
    end

    def description
      super
      "#{subject.description} changed attribute '#{attr_name}' value from '#{self[:old_value]}' to '#{self[:new_value]}'."
    end
  end # class ChangeAttribute
end # module Duxml