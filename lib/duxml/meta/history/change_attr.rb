require File.expand_path(File.dirname(__FILE__) + '/change')

module Duxml
  module ChangeAttr; end

  # created when Element has an attribute already and its value has been changed
  class ChangeAttrClass < ChangeClass
    include ChangeAttr

    # @param _subject [Duxml::Element] parent doc whose attribute changed
    # @param _attr_name [String] name of the changed attribute
    # @param _old_value [String] old attribute value
    def initialize(_subject, _attr_name, _old_value)
      super _subject
      @attr_name, @old_value = _attr_name, _old_value
    end

    attr_reader :attr_name, :old_value
  end # class ChangeAttributeClass

  module ChangeAttr
    # @return [String] new value of attribute
    def value
      subject[attr_name]
    end

    # @return [String] self description
    def description
      "#{super} #{subject.description}'s @#{attr_name} changed value from '#{old_value}' to '#{value}'."
    end
  end # module ChangeAttribute
end # module Duxml