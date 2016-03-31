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

    def initialize(*xml_or_args)
      @xml_root_node = class_to_xml *xml_or_args
      super xml_root_node[:id] || new_id
      return if text?
      @xml_root_node.children.each do |xml_child|
        class_name = xml_child.name.classify
        case
          when xml_child.text? && xml_child.content.match(/\w/)
            new_child = Dux::PCData.new(xml_child.content)
            add new_child
            xml_child.replace new_child.xml
          when Dux::constants.include?(class_name.to_sym)
            klass = Dux::const_get(class_name)
            self << klass.new(xml_child)
          when xml_child.element?
            klass = Class.new Object
            Dux::const_set class_name, klass
            self << klass.new(xml_child)
          else # skipping attributes
        end
      end
    end # def Dux::initialize xml_node, args={}
  end # class Object

  class PCData < Object
    def initialize(content)
      super element('p_c_data', content)
    end

    def description
      content
    end

    def xml
      content
    end

    def text?
      true
    end
  end
end # module Dux