require File.expand_path(File.dirname(__FILE__) + '/../../grammar/pattern')

module Duxml
  # pattern representing relationship between an object's attribute and its value
  class AttrValPattern
    include Pattern
    # @param _subject [Ox::Element] subject element
    # @param _attr_name [String] name of attribute
    def initialize(_subject, _attr_name)
      @subject = _subject
      @attr_name = _attr_name
    end

    attr_reader :subject, :attr_name

    def relationship
      'attribute value'
    end

    def description
      "#{subject.description}'s @#{attr_name} #{relationship} is #{value}"
    end

    # current value of this attribute
    def value
      subject[attr_name]
    end
  end # class AttrValPattern
end # module Duxml
