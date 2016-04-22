require File.expand_path(File.dirname(__FILE__) + '/change')

module Duxml
  module Add; end

  # created when an doc gains a child
  class AddClass < ChangeClass
    include Add

    def initialize(_subject, _index)
      super _subject
      @index = _index
    end

    alias_method :parent, :subject
    attr_reader :subject, :index
  end

  module Add
    def description
      super || %(#{child.description} was added to #{subject.description}.)
    end

    def parent
      subject
    end

    def child
      subject.nodes[index]
    end
  end # class Add
end # module Duxml