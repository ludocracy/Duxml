require File.expand_path(File.dirname(__FILE__) + '/../../grammar/pattern')

module Duxml
  # pattern representing relationship between an object and its child
  class ChildPattern < Pattern
    def relationship
      "#{super} ##{object.position+1}"
    end

    # overriding #object because one possible child pattern is having no children, in which case the object is the subject
    def object context_root=root
      obj = super
      obj.nil? ? subject(context_root) : obj
    end

    def description
      object == subject ? "#{subject.description} has no children" : super
    end
  end # class ChildPattern
end # module Duxml
