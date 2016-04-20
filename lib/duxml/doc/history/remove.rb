require File.expand_path(File.dirname(__FILE__) + '/change')

module Duxml
  # created when element loses a child
  class Remove < Change
    # @param _subject [Dux::Element] parent element that lost child
    # @param _child [Dux::Element] removed child; it gets added as child of this Remove object so it never actually goes away
    def initialize(_subject, _child)
      super(_subject)
      @removed = _child
    end

    attr_reader :removed

    # @return [String] describes removal event
    def description
      %(#{super} #{removed.description} was removed from #{subject.description}.)
    end
  end # class Remove
end # module Duxml