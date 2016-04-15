require File.expand_path(File.dirname(__FILE__) + '/edit')

module Duxml
  # created when object has no XML children but has text and text has been changed
  class ChangeContent < Edit
    # @param *args [*several_variants] XML or
    #   args[0] [Duxml::Object] object whose content has changed
    #   args[1] [String] the old content
    def initialize(*args)
      return super *args if xml? args
      raise Exception if args.size != 2
      super(subject: args.first, old_content: args[1], new_content: args[0].content)
    end

    # @return [String] self description
    def description
      super
      "#{subject.description} changed content from '#{old_content}' to '#{new_content}'."
    end

    # @return [String] old content
    def old_content
      self[:old_content]
    end

    # @return [String] new content (subsequent changes may mean this new content no longer exists in its original form!)
    def new_content
      self[:new_content]
    end
  end # class ChangeContent
end # module Duxml