require File.expand_path(File.dirname(__FILE__) + '/change')

module Duxml
  # created when object had no children or text and text has been added
  class NewText < Change
    # @param _subject [Duxml::Element] element that has gained new text
    # @param _index [Fixnum] index of new text node
    def initialize(_subject, _index)
      super _subject
      @index = _index
    end

    attr_reader :index

    def text
      subject[index]
    end

    # @return [String] self description
    def description
      "#{super} #{subject.description} given new text '#{text}'."
    end
  end # class NewContent
end # module Duxml