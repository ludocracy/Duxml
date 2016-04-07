require File.expand_path(File.dirname(__FILE__) + '/change')

module Duxml
  # created when object loses a child
  class Remove < Change
    # removed child is added as child of this Remove object so it never actually goes away
    def initialize(*args)
      if class_to_xml *args
        removed_child = args.first[:object]
        @xml.remove_attribute 'object'
      end
      super()
      self << removed_child if removed_child
    end

    def description
      super ||
          %(#{removed.description} was removed from #{subject.description}.)
    end

    # returns removed object
    def removed
      object
    end
  end # class Remove
end # module Duxml