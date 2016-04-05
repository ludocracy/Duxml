require File.expand_path(File.dirname(__FILE__) + '/../dux/meta/history')
require File.expand_path(File.dirname(__FILE__) + '/../dux/meta/grammar.rb')

module Dux
  class Meta < Object
    def initialize(xml_node=nil)
      if xml_node.nil?
        xml_node = super
        xml_node << Dux::Grammar.new.xml
        xml_node << Dux::History.new.xml
        xml_node
      else
        super xml_node
      end
    end

    # searches entire file plus metadata for an object matching given target
    def find(target)
      n = target.respond_to?(:name) ? target.name : target.to_s
      last_child.each do |node|
        return node if node.name == n
      end
      nil
    end

    # returns Dux::History
    def history
      find_child 'history'
    end

    # returns Dux::Grammar
    def grammar
      find_child 'grammar'
    end

    # adding Dux::Design or XML to Dux::Meta will add it to object tree but not to XML
    # to retain properties of original XML document
    def <<(obj)
      add coerce obj
      self
    end

    # returns XML design content as Dux::Object tree
    def design
      last_child
    end

    def grammar=(grammar_file)
      unless grammar.has_children?
        index = grammar.position
        remove 'grammar'
        add Grammar.new(grammar_file), index
      end
    end
  end # class Meta
end # module Dux