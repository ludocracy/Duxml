require File.expand_path(File.dirname(__FILE__) + '/../../grammar/pattern')

module Duxml
  # pattern representing relationship between an object's attribute and its value
  class AttrValPattern < Pattern
    # @param *args [*several_variants] XML or
    #   args[0] => subject element
    #   args[1] => name of attribute
    def initialize(*args)
      return super *args if xml? args
      raise Exception unless args.size == 2
      super({subject: args.first, attr_name: args.last})
    end

    def relationship
      'attribute value'
    end

    def description
      "#{subject.description}'s @#{attr_name} #{relationship} is #{value}"
    end

    # name of the attribute whose value is the actual object of this Pattern
    def attr_name
      self[:attr_name]
    end

    # current value of this attribute
    def value(meta=root)
      subject(meta)[attr_name]
    end
  end # class AttrValPattern
end # module Duxml
