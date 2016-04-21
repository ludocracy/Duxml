require File.expand_path(File.dirname(__FILE__) + '/../../grammar/pattern')

module Duxml
  # pattern representing relationship between an object and one of its attributes
  class AttrNamePattern
    include Pattern
    # @param _subject [Duxml::Element] subject doc
    # @param _attr_name [String] name of attribute
    def initialize(_subject, _attr_name)
      @subject = _subject
      @attr_name = _attr_name
    end

    attr_reader :attr_name

    def relationship
      'attribute'
    end

    # @return [Boolean] true if subject does not have the attr_name; false otherwise
    def abstract?
      subject[attr_name].nil?
    end

    def description
      abstract? ? "#{subject.description} does not have #{relationship} #{attr_name}" :
          "@#{attr_name} is #{relationship} of #{subject.description}"
    end
  end # class AttrNamePattern
end # module Duxml
