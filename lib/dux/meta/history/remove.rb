require File.expand_path(File.dirname(__FILE__) + '/change')

module Dux
  # created when object loses a child
  class Remove < Change
    def initialize(*args)
      if class_to_xml *args
        removed_child = args.first[:object]
        @xml_root_node.remove_attribute 'object'
      end
      super xml_root_node
      self << removed_child if removed_child
    end

    def description
      super ||
          %(Element '#{removed.id}' of type '#{removed.type}' was removed from element '#{subject.id}' of type '#{subject.type}'.)
    end

    def removed
      object
    end
  end
end