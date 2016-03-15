require File.expand_path(File.dirname(__FILE__) + '/ruby_ext/nokogiri')
require File.expand_path(File.dirname(__FILE__) + '/ruby_tree_ext/tree')
require File.expand_path(File.dirname(__FILE__) + '/ruby_ext/object')
require File.expand_path(File.dirname(__FILE__) + '/object/interface')
require File.expand_path(File.dirname(__FILE__) + '/object/guts')

module Dux
  class Object < Tree::TreeNode
    include ObjectInterface
    include ObjectGuts

    @xml_root_node
    @xml_cursor

    attr_reader :children, :children_hash, :xml_root_node

    alias_method :id, :name

    def initialize xml_node, args={}
      @reserved_word_array = args[:reserved] || []
      @xml_root_node = @xml_cursor = xml_node.nil? ? class_to_xml(args) : xml_node.xml
      @xml_root_node[:id] ||= xml_root_node.name+object_id.to_s
      # must happen before traverse to have @children/@children_hash available
      super xml_root_node[:id], xml_root_node.content
      # traverse and load Component from xml
      traverse_xml exec_methods %w(do_nothing init_reserved init_generic)
    end # def Dux::initialize xml_node, args={}
  end # class Object
end # module Dux