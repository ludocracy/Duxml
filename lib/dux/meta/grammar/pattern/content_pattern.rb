require File.expand_path(File.dirname(__FILE__) + '/../../grammar/pattern')

module Dux
  # pattern representing relationship between an object and its text-only child
  class ContentPattern < Pattern
    def object
      content
    end

    def description
      "#{relationship} of #{subject.description}"
    end
  end # class ContentPattern
end # module Dux
