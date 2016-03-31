require File.expand_path(File.dirname(__FILE__) + '/change')

module Dux
  # created when object loses a child
  class Remove < Change
    private def class_to_xml *args
              return args.first.xml if args.first.xml
              removed_child = args.first[:object].xml
              xml_node = super *args
              xml_node << removed_child
              xml_node.remove_attribute 'object'
              xml_node
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