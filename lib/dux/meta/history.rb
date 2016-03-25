require File.expand_path(File.dirname(__FILE__) + '/../../dux/meta/history/add')
require File.expand_path(File.dirname(__FILE__) + '/../../dux/meta/history/remove')
require File.expand_path(File.dirname(__FILE__) + '/../../dux/meta/history/error')
require File.expand_path(File.dirname(__FILE__) + '/../../dux/meta/history/edit')

module Dux
  class History < Object
    include Enumerable

    attr_reader :rules

    def initialize xml_node=nil, args={}
      super class_to_xml(xml_node), reserved: %w(add remove change_content change_attribute new_content new_attribute error correction instantiate move undo)
    end

    private def class_to_xml xml_node
      if xml_node.nil?
        %(<history><add id="change_0" owner="system"><description>file created</description><date>#{Time.now.to_s}</date></add></history>)
      else
        xml_node
      end
    end

    def update type, change_hash
      change_class = Dux::const_get type.to_s.classify
      change_comp = change_class.new(nil, change_hash)
      add change_comp, 0
      @xml_root_node.prepend_child change_comp.xml
      unless change_comp.type[-5..-1] == 'error' || root.grammar.nil?
        root.grammar.qualify change_comp
      end
      sleep 0
    end

    def each &block
      children.each &block
    end

    def last
      last_child
    end

    def [] key
      find_child key
    end
  end # class History
end # module Dux