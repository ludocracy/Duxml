require File.expand_path(File.dirname(__FILE__) + '/../../grammar/pattern')

module Dux
  # pattern representing relationship between an object and its child
  class AttrNamePattern < Pattern
    def object context_root=nil
      self[:object]
    end

    def relationship
      'attribute'
    end

    def description
      object.nil? ? "#{subject.description} has no attributes" :
          "@#{object} is #{relationship} of #{subject.description}"
    end
  end # class AttrNamePattern
end # module Dux
