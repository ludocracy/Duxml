require File.expand_path(File.dirname(__FILE__) + '/../../grammar/pattern')

module Dux
  # pattern representing relationship between an object's attribute and its value
  class AttrValPattern < Pattern
    def relationship
      'attribute value'
    end

    def description
      "#{subject.description}'s @#{attr_name} #{relationship} is #{value}"
    end

    def attr_name
      object
    end

    def value(meta=root)
      subject(meta)[attr_name]
    end
  end # class AttrValPattern
end # module Dux
