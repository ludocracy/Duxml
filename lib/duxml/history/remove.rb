require File.expand_path(File.dirname(__FILE__) + '/change')

module Duxml
  # created when object loses a child
  class Remove < Change
    # @param *args [*several_variants] XML or
    #   args[0] => parent that lost child
    #   args[1] => removed child; it gets added as child of this Remove object so it never actually goes away
    def initialize(*args)
      return super *args if xml? args
      raise Exception if args.size != 2
      removed_child = args.last
      super(subject: args.first)
      self << removed_child
    end

    # @return [Duxml::Object] object that lost child
    def affected_parent
      subject
    end

    def description
      super ||
          %(#{removed.description} was removed from #{subject.description}.)
    end

    # @return [Duxml::Object] removed object
    def removed
      object
    end
  end # class Remove
end # module Duxml