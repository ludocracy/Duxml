require File.expand_path(File.dirname(__FILE__) + '/../../grammar/pattern')

module Duxml
  # pattern representing relationship between an object and one of its attributes
  class AttrNamePattern < Pattern
    # @param *args [*several_variants] XML or
    #   args[0] => subject element
    #   args[1] => name of attribute
    def initialize(*args)
      return super *args if xml? args
      raise Exception unless args.size == 2
      super({subject: args.first, attr_name: args.last})
    end

    # @return [String] name of the attribute
    def attr_name
      self[:attr_name]
    end

    def relationship
      'attribute'
    end

    # @return [Boolean] true if subject does not have the attr_name; false otherwise
    def abstract?(context_root=meta)
      s = subject(context_root)
      s[attr_name].nil?
    end

    def description
      abstract? ? "#{subject.description} does not have #{relationship} #{attr_name}" :
          "@#{attr_name} is #{relationship} of #{subject.description}"
    end
  end # class AttrNamePattern
end # module Duxml
