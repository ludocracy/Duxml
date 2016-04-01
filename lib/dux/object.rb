require File.expand_path(File.dirname(__FILE__) + '/ruby_ext/nokogiri')
require File.expand_path(File.dirname(__FILE__) + '/ruby_tree_ext/tree')
require File.expand_path(File.dirname(__FILE__) + '/ruby_ext/object')
require File.expand_path(File.dirname(__FILE__) + '/object/interface')
require File.expand_path(File.dirname(__FILE__) + '/object/guts')

module Dux

  # Dux::Object is a Ruby Object combined with a Tree::TreeNode's methods via subclassing
  # With some restrictions, this allows Dux::Object to behave like an XML element with attributes and children
  # note that text nodes are converted into <p_c_data> elements in order to treat them as a Class i.e. Dux::PCData
  class Object < Tree::TreeNode
    include ObjectInterface
    include ObjectGuts

    @xml_root_node
    @xml_cursor

    attr_reader :children, :children_hash, :xml_root_node

    alias_method :id, :name

    # all Dux::Objects are initialized as either XML (see Nokogiri::XML::Node#initialize)
    # or as arguments that can be customized by each subclass's private #class_to_xml method.
    # by default, arguments that are not XML are interpreted as arguments to #element in order
    # to create the XML required to initialize this Dux::Object
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

  # Dux class for XML text nodes
  class PCData < Object
    # always initialized from a string, either via interface or from XML text
    def initialize(content)
      super element('p_c_data', content)
    end

    def description
      content
    end

    # this method returns PCData as XML text
    def xml
      content
    end

    # this is a text node
    def text?
      true
    end
  end
end # module Dux