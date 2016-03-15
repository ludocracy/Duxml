require File.expand_path(File.dirname(__FILE__) + '/../dux/meta/history')
require File.expand_path(File.dirname(__FILE__) + '/../dux/meta/grammar.rb')

module Dux
  class Meta < Object

    def initialize xml_node=nil, args = {}
      super class_to_xml(xml_node), reserved: %w(history grammar)
    end

    def find target
      n = target.respond_to?(:name) ? target.name : target.to_s
      last_child.each do |node|
        return node if node.name == n
      end
      nil
    end

    def history
      find_child 'history'
    end

    def grammar
      find_child 'grammar'
    end

    def design
      last_child
    end

    def grammar= grammar_file
      unless grammar.has_children?
        index = grammar.position
        remove 'grammar'
        add Grammar.new(grammar_file), index
      end
    end

    def class_to_xml xml_node
      if xml_node.nil?
        Nokogiri::XML(%(
          <meta id="temp_id">
            <grammar/>
            <history>
              <add id="change_0">
                  <description>initial commit</description>
                  <date>#{Time.now.to_s}</date>
              </add>
          </meta>)).root
      else
        xml_node
      end
    end

    private :class_to_xml
  end # class Meta
end # module Dux