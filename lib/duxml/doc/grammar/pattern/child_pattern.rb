require File.expand_path(File.dirname(__FILE__) + '/../../grammar/pattern')

module Duxml
  # pattern representing relationship between an object and its child
  class ChildPattern
    include Pattern

    # @param _subject [Duxml::Element] parent element of child
    # @param _index [Fixnum] index of child
    def initialize(_subject, _index)
      @subject, @index = _subject, _index
    end

    def parent
      subject
    end

    attr_reader :index


    def child
      subject.nodes[index]
    end
    alias_method :object, :child

    # @return [String] describes relationship between parent and child
    def relationship
      "#{super} ##{index+1}"
    end

    # @return [String] description of this child pattern
    def description
      ph = child.nil? ? ' has no children' : " is missing <#{child}>"
      "#{subject.description} #{ph}"
    end
  end # class ChildPattern
end # module Duxml
