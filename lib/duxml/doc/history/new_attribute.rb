require File.expand_path(File.dirname(__FILE__) + '/change')

module Duxml
  # created when element gains a new attribute
  class NewAttribute < Change
    # @param _subject [Duxml::Element] parent element
    # @param _attr_name
    def initialize(_subject, _attr_name)
      super(_subject)
      @attr_name = _attr_name
    end

    attr_reader :attr_name

    # @return [String] value of the new attribute
    def value
      subject[attr_name]
    end

    # @return [String] self description
    def description
      "#{super} #{subject.description} given new attribute '#{self[:attr_name]}' with value '#{self[:new_value]}'."
    end
  end # class NewAttribute
end # module Duxml