require File.expand_path(File.dirname(__FILE__) + '/../ruby_ext/object')
require 'ox'

module Ox
  # serializes given object into XML, wrapping Ox's Element.new
  # if obj is Ox::Node, closest Ox::Element
  # if obj is String:
  #   xml('<node/>')   => #<Ox::Element:0xffff @value='node', @attributes={}, @nodes=[]>
  #   xml('asdf asdf') => 'asdf asdf'
  #
  # if obj is not String or Ox::Node:
  #   module Maudule
  #     def self.xml
  #       Element(self.to_s)
  #     end
  #
  #     class Klass
  #       attr_reader :name, :children
  #
  #       def initialize(_name)
  #         @name = _name
  #         @children = []
  #       end
  #
  #       def <<(obj)
  #         @children << obj
  #         self
  #       end
  #
  #       def each(&block)
  #         @children.each(&block)
  #       end
  #     end
  #   end
  #
  #   k = Maudule::Klass.new('node')   => #<Maudule::Klass:0x000000034988d0 @name="node", @children=[]>
  #   k << Maudule::Klass.new('child') => #<Maudule::Klass:0x000000034988d0 @name="node", @children=[#<Maudule::Klass:0x000000034a0c10 @name="child", @children=[]>]>
  #   xml(k).to_s                      => <maudule:klass name="node"><maudule:klass name="child"/></maudule:klass>
  #
  #   # if module does NOT have #self.xml defined, then this will return the constant symbol (Module) serialized into XML
  #   xml(Maudule)                     => #<Ox::Element:0x000000034988e0 @value="maudule", @attributes={}, @children=[]>
  #
  # @param obj [*several_variants] object to be converted to XML
  # @return [Ox::Element]
  def xml(obj)
    return obj if obj.is_a?(Ox::Element)
    return obj.root if obj.is_a?(Ox::Document)
    return(obj[0]=='<' && obj[-1]=='>' ? Ox.parse(obj) : obj) if obj.is_a?(String)
    return obj.xml if obj.respond_to?(:xml)
    el = Ox::Element.new nmtoken(obj)
    obj.instance_variables.each do |var|
      if var == :@children
        obj.children.each do |child| el << xml(child) end
      elsif obj.instance_variable_defined?(var)
        attr_name = var.to_s[1..-1]
        el[attr_name] = obj.instance_variable_get(var)
      else # do nothing
      end
    end
    el
  end # def xml(obj)

  private
  def nmtoken(obj)
    "#{obj.simple_module == 'Module' ? '' : "#{obj.simple_module.nmtokenize}:"}#{obj.simple_class.nmtokenize}"
  end
end # module Ox