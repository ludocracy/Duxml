require File.expand_path(File.dirname(__FILE__) + '/../duxml/meta/history')
require File.expand_path(File.dirname(__FILE__) + '/../duxml/meta/grammar.rb')

module Duxml
  class Meta < Object
    # TODO code looks a little dated; use #xml? ?
    # can only be initialized from XML or created as anonymous detached metadata to be attached to content by external entity
    #
    # @param xml_node [Nokogiri::XML::Node] XML from metadata (e.g. for file.xml, .file.duxml) file
    def initialize(xml_node=nil)
      if xml_node.nil?
        xml_node = super
        xml_node << Duxml::Grammar.new.xml
        xml_node << Duxml::History.new.xml
        xml_node
      else
        super xml_node
      end
    end

    # @param target [String|Symbol] name of desired Object
    # @return [Duxml::Object] found Object or nil
    def find(target)
      n = target.respond_to?(:name) ? target.name : target.to_s
      last_child.each do |node|
        return node if node.name == n
      end
      nil
    end

    # @return [Duxml::History]
    def history
      find_child 'history'
    end

    # @return [Duxml::Grammar]
    def grammar
      find_child 'grammar'
    end

    # adding Duxml::Design or XML to Duxml::Meta will add it to object tree but not to XML
    # to retain properties of original XML document
    # TODO should this add XML some times? for file-specific metadata clearly yes...
    # @param obj [String|Nokogiri::XML::Node|Duxml::Object]
    # @return [Duxml::Object] self
    def <<(obj)
      add coerce obj
      self
    end

    # @return [Duxml::Object] root node of XML design content
    def design
      last_child
    end

    # add an external grammar
    #
    # @param grammar_file [String] external grammar definition file
    def grammar=(grammar_file)
      unless grammar.has_children?
        index = grammar.position
        remove 'grammar'
        add Grammar.new(grammar_file), index
      end
    end
  end # class Meta
end # module Duxml