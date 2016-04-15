require File.expand_path(File.dirname(__FILE__) + '/edit')

module Duxml
  # created when object had no children or text and text has been added
  class NewContent < Edit
    # @param *args [*several_variants] XML or
    #   args[0] => Duxml::Object that has gained new content
    def initialize(*args)
      return super *args if xml? args
      raise Exception if args.size != 1
      super({subject: args.first, new_content: args.first.content})
    end

    # @return [String] self description
    def description
      super
      "#{subject.description} given new content '#{new_content}'."
    end

    # @return [String] new content
    def new_content
      self[:new_content]
    end
  end # class NewContent
end # module Duxml