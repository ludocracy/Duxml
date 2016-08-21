# Copyright (c) 2016 Freescale Semiconductor Inc.

require File.expand_path(File.dirname(__FILE__) + '/../../grammar/pattern')
require File.expand_path(File.dirname(__FILE__) + '/../../../ruby_ext/fixnum')

module Duxml
  module ChildPattern; end
  # pattern representing relationship between an object and its child
  class ChildPatternClass < PatternClass
    include ChildPattern

    # @param _subject [Duxml::Element] parent element
    # @param _child [Fixnum] child node
    def initialize(_subject, _child, _index)
      @child, @index = _child, _index
      super _subject
    end

    alias_method :parent, :subject
    attr_reader :child, :index
  end # class ChildPatternClass

  # null child patterns represent and parent child relationship where the child
  # is required by the Grammar but the element is missing that child
  class NullChildPatternClass < PatternClass
    include ChildPattern

    # @param _subject [Element] parent element
    # @param _missing_child [String] nmtoken for missing child element
    def initialize(_subject, _missing_child, _index=-1)
      @missing_child, @index = _missing_child, _index
      super _subject
    end

    def relationship
      'missing child'
    end

    # @return [String] description of this child pattern
    def description
      "#{subject.description} #{relationship} <#{child}>"
    end

    attr_reader :missing_child, :index
    alias_method :child, :missing_child
    alias_method :parent, :subject
  end

  module ChildPattern
    # @return [String] describes relationship between parent and child
    def relationship
      "#{(index+1).ordinal_name} #{super}"
    end

    # @return [String] description of this child pattern
    def description
      "#{subject.description}'s #{relationship} #{child.description}"
    end
  end
end # module Duxml
