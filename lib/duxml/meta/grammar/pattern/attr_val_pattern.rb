require File.expand_path(File.dirname(__FILE__) + '/../../grammar/pattern')

module Duxml
  # pattern representing relationship between an object's attribute and its value
  class AttrValPattern < Pattern
    def relationship
      'attribute value'
    end

    def description
      "#{subject.description}'s @#{attr_name} #{relationship} is #{value}"
    end

    # name of the attribute whose value is the actual object of this Pattern
    def attr_name
      object
    end

    # current value of this attribute
    def value(meta=root)
      subject(meta)[attr_name]
    end
  end # class AttrValPattern
end # module Duxml
