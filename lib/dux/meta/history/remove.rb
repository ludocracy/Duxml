require File.expand_path(File.dirname(__FILE__) + '/change')

module Dux
  # created when object loses a child
  class Remove < Change
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

    def removed
      object
    end
  end
end