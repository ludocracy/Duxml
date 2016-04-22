require File.expand_path(File.dirname(__FILE__) + '/change')

module Duxml
  module Remove; end

  # created when doc loses a child
  class RemoveClass < ChangeClass
    include Remove
    # @param _subject [Dux::Element] parent doc that lost child
    # @param _child [Dux::Element] removed child; it gets added as child of this Remove object so it never actually goes away
    def initialize(_subject, _child)
      super(_subject)
      @removed = _child
    end

    attr_reader :removed
  end

  module Remove
    # @return [String] describes removal event
    def description
      %(#{super} #{removed.description} was removed from #{subject.description}.)
    end
  end # module Remove
end # module Duxml