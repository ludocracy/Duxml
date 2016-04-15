require File.expand_path(File.dirname(__FILE__) + '/../../grammar/pattern')

module Duxml
  # pattern representing relationship between an object and its text-only child
  class ContentPattern < Pattern
    # object of this pattern is the text-only content of the subject, which is made the content of this Pattern
    def object
      content
    end

    def new_content
      content
    end

    def description
      "#{relationship} of #{subject.description}"
    end
  end # class ContentPattern
end # module Duxml
