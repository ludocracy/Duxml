require File.expand_path(File.dirname(__FILE__) + '/../../grammar/pattern')

module Duxml
  module ChildPattern; end
  # pattern representing relationship between an object and its child
  class ChildPatternClass < PatternClass
    include ChildPattern

    # @param _subject [Duxml::Element] parent doc of child
    # @param _index [Fixnum] index of child
    def initialize(_subject, _index)
      @index = _index
      super _subject
    end

    alias_method :parent, :subject
    attr_reader :index
  end # class ChildPatternClass

  class NullChildPatternClass < PatternClass
    include ChildPattern

    def initialize(_subject, require_child)
      @missing_child = require_child
      super _subject
    end

    def index
      -1
    end

    attr_reader :missing_child
    alias_method :child, :missing_child
    alias_method :parent, :subject
  end

  module ChildPattern
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
  end
end # module Duxml
