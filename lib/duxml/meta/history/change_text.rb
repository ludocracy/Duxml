# Copyright (c) 2016 Freescale Semiconductor Inc.

require File.expand_path(File.dirname(__FILE__) + '/change')

module Duxml
  module ChangeText; end
  # created when doc has text and text has been changed
  class ChangeTextClass < ChangeClass
    include ChangeText

    # @param _subject [Duxml::Element] parent doc whose text has changed
    # @param _index [Fixnum] index of parent's nodes that text is found at
    # @param _old_text [String] string that was replaced
    def initialize(_subject, _index, _old_text)
      super _subject
      @index, @old_text = _index, _old_text
    end

    attr_reader :index, :old_text
  end

  module ChangeText
    # @return [String] self description
    def description
      "#{super} #{subject.description}'s text at index #{index} changed from '#{old_text}' to '#{text}'."
    end

    # @return [String] new content (subsequent changes may mean this new content no longer exists in its original form!)
    def text
      subject.nodes[index]
    end
  end # module ChangeText
end # module Duxml