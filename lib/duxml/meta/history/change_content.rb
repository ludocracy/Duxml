require File.expand_path(File.dirname(__FILE__) + '/edit')

module Duxml
  # created when object has no XML children but has text and text has been changed
  class ChangeContent < Edit
    def initialize(*args)
      if class_to_xml *args
        @xml.remove_attribute 'object'
        @xml << args.first[:object]
      end
      super()
    end

    def description
      super
      "#{subject.description} changed content from '#{old_content}' to '#{new_content}'."
    end

    # content of element prior to change
    def old_content
      content
    end

    # content of element after change
    # TODO have this update if subsequent change affects content?
    def new_content
      subject.content
    end
  end # class ChangeContent
end # module Duxml