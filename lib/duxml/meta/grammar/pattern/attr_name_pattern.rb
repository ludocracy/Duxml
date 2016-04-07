require File.expand_path(File.dirname(__FILE__) + '/../../grammar/pattern')

module Duxml
  # pattern representing relationship between an object and one of its attributes
  class AttrNamePattern < Pattern
    # object here represents the name of the attribute
    def object(context_root=nil)
      self[:object]
    end

    alias_method :attr_name, :object

    def relationship
      'attribute'
    end

    def description
      object.nil? ? "#{subject.description} has no attributes" :
          "@#{object} is #{relationship} of #{subject.description}"
    end
  end # class AttrNamePattern
end # module Duxml
