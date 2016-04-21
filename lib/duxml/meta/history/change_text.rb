require File.expand_path(File.dirname(__FILE__) + '/change')

module Duxml
  # created when doc has text and text has been changed
  class ChangeText < Change
    # @param _subject [Duxml::Element] parent doc whose text has changed
    # @param _index [Fixnum] index of parent's nodes that text is found at
    # @param _old_text [String] string that was replaced
    def initialize(_subject, _index, _old_text)
      super _subject
      @index, @old_text = _index, _old_text
    end

    attr_reader :index, :old_text

    # @return [String] self description
    def description
      "#{super} #{subject.description} changed text from '#{old_text}' to '#{text}'."
    end

    # @return [String] new content (subsequent changes may mean this new content no longer exists in its original form!)
    def text
      subject[index]
    end
  end # class ChangeContent
end # module Duxml