require File.expand_path(File.dirname(__FILE__) + '/change')

module Duxml
  # created when Element has an attribute already and its value has been changed
  class ChangeAttribute < Change
    # @param _subject [Duxml::Element] parent doc whose attribute changed
    # @param _attr_name [String] name of the changed attribute
    # @param _old_value [String] old attribute value
    def initialize(_subject, _attr_name, _old_value)
      super _subject
      @attr_name, @old_value = _attr_name, _old_value
    end

    attr_reader :attr_name, :old_value

    # @return [String] new value of attribute
    def value
      subject[attr_name]
    end

    # @return [String] self description
    def description
      "#{super} #{subject.description} changed attribute '#{attr_name}' value from '#{old_value}' to '#{value}'."
    end
  end # class ChangeAttribute
end # module Duxml