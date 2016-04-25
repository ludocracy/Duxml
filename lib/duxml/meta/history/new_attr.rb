require File.expand_path(File.dirname(__FILE__) + '/change')

module Duxml
  module NewAttr; end

    # created when doc gains a new attribute
  class NewAttrClass < ChangeClass
    include NewAttr

    # @param _subject [Duxml::Element] parent doc
    # @param _attr_name
    def initialize(_subject, _attr_name)
      super(_subject)
      @attr_name = _attr_name
    end

    attr_reader :attr_name
  end

  module NewAttr
    # @return [String] value of the new attribute
    def value
      subject[attr_name]
    end

    # @return [String] self description
    def description
      "#{super} #{subject.description} given new attribute '#{attr_name}' with value '#{value}'."
    end
  end # module NewAttribute
end # module Duxml