require File.expand_path(File.dirname(__FILE__) + '/edit')

module Duxml
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

    # value of the new attribute
    def value(meta)
      subject(meta)[attr_name]
    end

    # name of new attribute
    def attr_name
      self[:attr_name]
    end

    def description
      super
      "#{subject.description} given new attribute '#{self[:attr_name]}' with value '#{self[:new_value]}'."
    end
  end # class NewAttribute
end # module Duxml