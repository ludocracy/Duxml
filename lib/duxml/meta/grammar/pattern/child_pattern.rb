require File.expand_path(File.dirname(__FILE__) + '/../../grammar/pattern')

module Duxml
  # pattern representing relationship between an object and its child
  class ChildPattern < Pattern
    # @return [String] describes relationship between parent and child
    def relationship
      "#{super} ##{object.position+1}"
    end

    # @return [String] description of this child pattern
    def description
      object ? super : "#{subject.description} has no children"
    end
  end # class ChildPattern
end # module Duxml
