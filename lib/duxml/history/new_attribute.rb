require File.expand_path(File.dirname(__FILE__) + '/edit')

module Duxml
  # created when object gains a new attribute
  class NewAttribute < Edit
    # @param *args [*several_variants] can be XML or
    #   args[0] => [Duxml::Object] parent object
    #   args[1] => [String, Symbol] name of attribute
    def initialize(*args)
      if xml? args
        super *args
      else
        raise Exception if args.size != 2
        super({subject: args[0],attr_name: args[1], new_value: args[0][args[1]]})
      end
    end

    # @param context_root [Duxml::Meta] context in which to evaluate the new attribute
    # @return [String] value of the new attribute
    def value(context_root=meta)
      subject(context_root)[attr_name]
    end

    # @return [String] name of new attribute
    def attr_name
      self[:attr_name]
    end

    # @return [String] self description
    def description
      super
      "#{subject.description} given new attribute '#{self[:attr_name]}' with value '#{self[:new_value]}'."
    end
  end # class NewAttribute
end # module Duxml