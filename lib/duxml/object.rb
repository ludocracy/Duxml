require File.expand_path(File.dirname(__FILE__) + '/ruby_ext/nokogiri')
require File.expand_path(File.dirname(__FILE__) + '/ruby_tree_ext/tree')
require File.expand_path(File.dirname(__FILE__) + '/object/interface')
require File.expand_path(File.dirname(__FILE__) + '/object/guts')

module Duxml
  # Duxml::Object is a Ruby Object combined with a Tree::TreeNode's methods via subclassing
  # With some restrictions, this allows Duxml::Object to behave like an XML element with attributes and children
  # note that text nodes are converted into <p_c_data> elements in order to treat them as a Class i.e. Duxml::PCData
  class Object < Tree::TreeNode
    include ObjectInterface
    include ObjectGuts

    # pointer to XML element corresponding to this Object
    @xml

    # inherited from Tree::TreeNode@children
    @children

    # inherited from Tree::TreeNode@children_hash
    @children_hash

    # points to Nokogiri::XML::Element that this Object represents
    @xml

    # when Object is initialized from XML document, initialized from Nokogiri::Element#line + 1 (TODO not sure why +1 needed here; make a constant?)
    @line

    attr_reader :children, :children_hash, :xml, :line

    # shortcutting #id to Tree::TreeNode@name, which must be unique among siblings only
    alias_method :id, :name

    # all Duxml::Objects are initialized as either XML (see Nokogiri::XML::Node#initialize)
    # or as arguments that can be customized by each subclass's private #class_to_xml method.
    # by default, arguments that are not XML are interpreted as arguments to #element in order
    # to create the XML required to initialize this Duxml::Object
    #
    # @param xml_or_args [Nokogiri::XML::Node|variant types] if not initializing from XML, arguments are, by default,
    #   interpreted as the second and third arguments for #element in order to create new XML
    def initialize(*xml_or_args)
      result = class_to_xml *xml_or_args
      @line = xml.line+1 unless result
      super xml[:id] || new_id
      return if text?
      xml.children.each do |xml_child|
        case
          when xml_child.element? || xml_child.text? && xml_child.content.match(/\S/)
            self << xml_child
          else # skipping attributes
        end
      end # @xml_root_node.children.each
    end # def Duxml::initialize xml_node, args={}
  end # class Object
end # module Duxml