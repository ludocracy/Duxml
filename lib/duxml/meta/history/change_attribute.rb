require File.expand_path(File.dirname(__FILE__) + '/edit')

module Duxml
  # created when object has a given attribute and its value has been changed
  class ChangeAttribute < Edit
    # @param *args [*several_variants] XML or
    #   args[0] => object whose attribute changed
    #   args[1] => name of the changed attribute
    #   args[2] => old attribute value
    def initialize(*args)
      if xml? args
        super *args
      else
        raise Exception if args.size != 3
        super({subject: args[0], attr_name: args[1], old_value: args[2], new_value: args[0][args[1]]})
      end
    end

    # @return [String] name of the attribute that was changed
    def attr_name
      self[:attr_name]
    end

    # @return [String] old value of the attribute
    def old_value
      self[:old_value]
    end


    # @return [String] new value of attribute
    def value
      self[:new_value]
    end

    alias_method :new_value, :value
    # @return [String] self description
    def description
      super
      "#{subject.description} changed attribute '#{attr_name}' value from '#{old_value}' to '#{value}'."
    end
  end # class ChangeAttribute
end # module Duxml