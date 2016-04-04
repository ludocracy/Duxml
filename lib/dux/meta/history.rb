require File.expand_path(File.dirname(__FILE__) + '/../../dux/meta/history/add')
require File.expand_path(File.dirname(__FILE__) + '/../../dux/meta/history/remove')
require File.expand_path(File.dirname(__FILE__) + '/../../dux/meta/history/error')
require File.expand_path(File.dirname(__FILE__) + '/../../dux/meta/history/edit')

module Dux
  class History < Object
    include Enumerable

    def description
      "history follows: \n" +
      children.collect do |change_or_error|
        change_or_error.description
      end.join("\n")
    end

    private def class_to_xml(xml_node)
      if xml_node.nil?
        xml_node = super xml_node
        xml_node << %(<add owner="system" date="#{Time.now.to_s}"><description>file created</description></add>)
        xml_node
      else
        super xml_node
      end
    end

    # receives reports from interface of changes or from Dux::Rule violations
    def update(type, change_hash)
      change_class = Dux::const_get type.to_s.classify
      change_comp = change_class.new change_hash
      add change_comp, 0
      @xml_root_node.prepend_child change_comp.xml
      unless change_comp.type[-5..-1] == 'error' || root.grammar.nil?
        root.grammar.qualify change_comp
      end
      sleep 0
    end

    # override #each to return only children
    def each(&block)
      children.each &block
    end

    # override #[] to return child of history
    def [](key)
      find_child key
    end
  end # class History
end # module Dux