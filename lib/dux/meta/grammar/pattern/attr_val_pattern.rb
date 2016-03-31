require File.expand_path(File.dirname(__FILE__) + '/../../grammar/pattern')

module Dux
  # pattern representing relationship between an object and its child
  class AttrValPattern < Pattern
    private def class_to_xml *args
              return args.first.xml if args.first.xml
              h = {subject: args.first, object: args.last}
              xml_node = super h
              xml_node[:subject] = args.first
              xml_node[:object] = args.last
              xml_node
    end
  end # class AttrValPattern
end # module Dux
