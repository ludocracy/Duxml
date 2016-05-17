# Copyright (c) 2016 Freescale Semiconductor Inc.

require File.expand_path(File.dirname(__FILE__) + '/../../grammar/pattern')

module Duxml
  module AttrValPattern; end

  # pattern representing relationship between an object's attribute and its value
  class AttrValPatternClass < PatternClass
    include AttrValPattern

    # @param _subject [Element] subject element
    # @param _attr_name [String] name of attribute whose value is the object of this pattern
    def initialize(_subject, _attr_name)
      @attr_name = _attr_name
      super _subject
    end

    attr_reader :subject, :attr_name
  end

  module AttrValPattern
    def relationship
      'value'
    end

    def description
      "#{subject.description}'s @#{attr_name} #{relationship} of '#{value}'"
    end

    # current value of this attribute
    def value
      subject[attr_name]
    end
  end # class AttrValPattern
end # module Duxml
