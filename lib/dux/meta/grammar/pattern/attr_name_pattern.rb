require File.expand_path(File.dirname(__FILE__) + '/../../grammar/pattern')

module Dux
  # pattern representing relationship between an object and its child
  class AttrNamePattern < Pattern
    def object
      self[:object]
    end

    def relationship
      'attribute name'
    end

    def description
      object.nil? ? "#{subject.description} has no attributes" : super
    end
  end # class AttrNamePattern
end # module Dux
