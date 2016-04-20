require File.expand_path(File.dirname(__FILE__) + '/../../grammar/pattern')

module Duxml
  # pattern representing relationship between an object and its text-only child
  class TextPattern
    include Pattern


    # @param _subject [Ox::Element] parent of text node
    # @param _index [Fixnum] index of text node
    def initialize(_subject, _index)
      @subject, @index = _subject, _index
    end

    attr_reader :subject, :index

    def text
      affected_parent.nodes[index]
    end

    def description
      "#{relationship} of #{subject.description}"
    end
  end # class ContentPattern
end # module Duxml
