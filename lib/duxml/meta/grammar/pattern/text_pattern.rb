# Copyright (c) 2016 Freescale Semiconductor Inc.

require File.expand_path(File.dirname(__FILE__) + '/../../grammar/pattern')

module Duxml
  module TextPattern; end
  # pattern representing relationship between an object and its text-only child
  class TextPatternClass < PatternClass
    include TextPattern

    # @param _subject [Ox::Element] parent of text node
    # @param _index [Fixnum] index of text node
    def initialize(_subject, _str, _index)
      @index = _index
      @string = _str
      super _subject
    end

    attr_reader :subject, :index, :str
  end

  module TextPattern
    def text
      subject.nodes[index]
    end

    def description
      "#{subject.description}'s #{relationship} is '#{text}'"
    end
  end # class ContentPattern
end # module Duxml
