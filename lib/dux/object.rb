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

    #pointer to XML element corresponding to this Object
    @xml_root_node

    attr_reader :children, :children_hash, :xml_root_node, :line

    alias_method :id, :name

    # all Dux::Objects are initialized as either XML (see Nokogiri::XML::Node#initialize)
    # or as arguments that can be customized by each subclass's private #class_to_xml method.
    # by default, arguments that are not XML are interpreted as arguments to #element in order
    # to create the XML required to initialize this Dux::Object
    def initialize(*xml_or_args)
      @xml_root_node = class_to_xml *xml_or_args
      @line = xml_root_node.line+1 if xml_or_args.first && (xml_root_node == xml_or_args.first)
      super xml_root_node[:id] || new_id
      return if text?
      @xml_root_node.children.each do |xml_child|
        case
          when xml_child.text? && xml_child.content.match(/\w/)
            new_child = Dux::PCData.new(xml_child.content)
            self << new_child
          when xml_child.element?
            self << xml_child
          else # skipping attributes
        end # case ... Nokogiri::XML::Node types
      end # @xml_root_node.children.each
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

    # dissolves object into String
    def to_s
      xml_root_node.content
    end

    # this method returns PCData as XML text
    def xml
      to_s
    end

    # this is a text node
    def text?
      true
    end
  end
end # module Dux