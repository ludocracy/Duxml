require File.expand_path(File.dirname(__FILE__) + '/../../grammar/pattern')

module Duxml
  module AttrNamePattern; end
  # pattern representing relationship between an object and one of its attributes
  class AttrNamePatternClass < PatternClass
    include AttrNamePattern

    # @param _subject [Duxml::Element] subject doc
    # @param _attr_name [String] name of attribute
    def initialize(_subject, _attr_name)
      @attr_name = _attr_name
      super _subject
    end

    attr_reader :attr_name
  end

  module AttrNamePattern
    def relationship
      'attribute'
    end

    # @return [Boolean] true if subject does not have the attr_name; false otherwise
    def abstract?
      subject[attr_name].nil?
    end

    def description
      abstract? ? "#{subject.description} does not have #{relationship} [#{attr_name}]" :
          "#{subject.description}'s #{relationship} [#{attr_name}]"
    end
  end # class AttrNamePattern
end # module Duxml
