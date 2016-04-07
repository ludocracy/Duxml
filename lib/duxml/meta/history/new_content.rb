require File.expand_path(File.dirname(__FILE__) + '/edit')

module Duxml
  # created when object had no children or text and text has been added
  class NewContent < Edit
    def description
      super
      "#{subject.description} given new content '#{new_content}'."
    end

    # new content
    # TODO update if subsequent changes to content?
    def new_content
      subject.content
    end
  end # class NewContent
end # module Duxml