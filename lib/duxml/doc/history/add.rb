require File.expand_path(File.dirname(__FILE__) + '/change')

module Duxml
  # created when an element gains a child
  class Add < Change
    def initialize(_subject, _index)
      super _subject
      @index = _index
    end

    attr_reader :subject, :index

    def description
      super || %(#{child.description} was added to #{subject.description}.)
    end

    def affected_parent
      subject
    end

    def child
      subject[index]
    end
  end # class Add
end # module Duxml