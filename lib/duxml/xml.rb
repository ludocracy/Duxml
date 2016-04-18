require File.expand_path(File.dirname(__FILE__) + '/../duxml/ox_ext/document')

module Duxml
  module XML
    include Ox
    # serializes given object into XML, wrapping Ox's #dump behavior to match Duxml's requirements
    # if obj is Ox::Node, closest Ox::Element
    # if obj is String:
    #   x = xml('<node/>').to_s   => '<node/>'
    #   File.write('file.xml', x)
    #   xml('file.xml').to_s      => '<node/>'
    #
    # if obj is not String or Ox::Node:
    #   module Maudule
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
    #   k = Maudule::Klass.new('node')      => #<Maudule::Klass:0x000000034988d0 @name="node", @children=[]>
    #   k << Maudule::Klass.new('child')    => #<Maudule::Klass:0x000000034988d0 @name="node", @children=[#<Maudule::Klass:0x000000034a0c10 @name="child", @children=[]>]>
    #   xml(k).to_s                         => <maudule:klass name="node"><maudule:klass name="child"/></maudule:klass>
    #
    # @param obj [*several_variants] object to be converted to XML
    # @return [Ox::XML::Element]
    def xml(obj)
      return obj if obj.is_a?(Ox::Element)
      return obj.root if obj.is_a?(Ox::Document)
      begin
        if obj.is_a?(String)
          x = if obj[0]=='<' && obj[-1]=='>'
                obj
              else
                if File.exists?(obj)
                  File.open(obj)
                else
                  raise ArgumentError, "'#{obj}' is not a valid XML string or file path"
                end
              end
          return Ox.parse(x).root
        end
        el = Ox::Element.new(nmtoken obj)
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
      end
    end # def xml(obj)

    private
    def nmtoken(obj)
      "#{obj.simple_module == 'Module' ? '' : "#{obj.simple_module.nmtokenize}:"}#{obj.simple_class.nmtokenize}"
    end
  end # module XML
end # module Duxml