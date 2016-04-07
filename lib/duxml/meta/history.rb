require File.expand_path(File.dirname(__FILE__) + '/../../duxml/meta/history/add')
require File.expand_path(File.dirname(__FILE__) + '/../../duxml/meta/history/remove')
require File.expand_path(File.dirname(__FILE__) + '/../../duxml/meta/history/validate_error')
require File.expand_path(File.dirname(__FILE__) + '/../../duxml/meta/history/qualify_error')
require File.expand_path(File.dirname(__FILE__) + '/../../duxml/meta/history/new_attribute')
require File.expand_path(File.dirname(__FILE__) + '/../../duxml/meta/history/change_attribute')
require File.expand_path(File.dirname(__FILE__) + '/../../duxml/meta/history/new_content')
require File.expand_path(File.dirname(__FILE__) + '/../../duxml/meta/history/change_content')
require File.expand_path(File.dirname(__FILE__) + '/../../duxml/meta/history/undo')

module Duxml
  class History < Object
    include Enumerable

    def description
      "history follows: \n" +
      children.collect do |change_or_error|
        change_or_error.description
      end.join("\n")
    end

    def initialize(xml_node=nil)
      if class_to_xml xml_node
        @xml << %(<add owner="system" date="#{Time.now.to_s}"><description>file created</description></add>)
      end
      super()
    end

    # receives reports from interface of changes or from Duxml::Rule violations
    def update(type, change_hash)
      change_class = Duxml::const_get type.to_s.classify
      change_comp = change_class.new change_hash
      add change_comp, 0
      @xml.prepend_child change_comp.xml
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
end # module Duxml