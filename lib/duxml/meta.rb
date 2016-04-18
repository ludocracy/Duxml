require File.expand_path(File.dirname(__FILE__) + '/../duxml/meta/history')
require File.expand_path(File.dirname(__FILE__) + '/../duxml/meta/grammar.rb')

module Duxml
  class Meta
    # TODO code looks a little dated; use #xml? ?
    # can only be initialized from XML or created as anonymous detached metadata to be attached to content by external entity
    #
    # @param xml_node [Nokogiri::XML::Node] XML from metadata (e.g. for file.xml, .file.duxml) file
    def initialize(xml_node=nil)
      if xml_node.nil?
        @xml = element simple_class
        @xml << Duxml::Grammar.new.xml
        @xml << Duxml::History.new.xml
        super xml
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
    # also updates XML if updates are to file-specific metadata
    # @param obj [String|Nokogiri::XML::Node|Duxml::Object]
    # @return [Duxml::Object] self
    def <<(obj)
      add coerce obj
      @xml << obj.xml if %w{name owner history}.include?(obj.simple_class)
      self
    end

    # @return [Duxml::Object] root node of XML design content
    def design
      last_child
    end

    # add an external grammar
    #
    # @param grammar_or_file [Duxml::Grammar, String] a grammar object or external grammar definition file
    #   for now, if grammar already defined, will ignore this method
    def grammar=(grammar_or_file)
      unless grammar.defined?
        index = grammar.position
        remove 'grammar'
        if grammar_or_file.respond_to?(:qualify)
          new_grammar = grammar_or_file
          file = new_grammar.file
        else
          new_grammar = Grammar.new(grammar_or_file)
          file = grammar_or_file
        end
        add new_grammar, index
        @xml.element_children.last.add_previous_sibling element('grammar')
        @xml.xpath("//grammar").first[:ref] = file
      end
    end
  end # class Meta
end # module Duxml