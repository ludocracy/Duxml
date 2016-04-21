require File.expand_path(File.dirname(__FILE__) + '/doc')

module Duxml
  module Saxer
    @io

    attr_accessor :io
    # @param path [String] path of file to parse
    # @return [Doc] finished document with each Element's line and column info added
    def sax(path, *obs)
      io = File.open path
      saxer = DocuLiner.new(Duxml::Doc.new, *obs)
      Ox.sax_parse(saxer, io, {convert_special: true, symbolize: false})
      saxer.cursor
    end

    class DocuLiner < ::Ox::Sax
      # @param doc [Ox::Document] document that is being constructed as XML is parsed
      # @param *_observers [*several_variants] objects that will observe this document's content
      def initialize(doc, *_observers)
        @cursor_stack = [doc]
        @line = 0
        @column = 0
        @observers = []#_observers
      end

      attr_reader :line, :column, :observers

      def cursor
        cursor_stack.last
      end

      attr_accessor :cursor_stack

      def start_element(name)
        cursor << Duxml::Element.new(name, line, column)
        observers.each do |obs| cursor.add_observer(obs) end
        cursor_stack << cursor.nodes.last
      end

      def attr(name, val)
        cursor[name] = val
      end

      def text(str)
        cursor << str
      end

      def end_element(name)
        @cursor_stack.pop
      end

      private

      def doc
        cursor_stack.first
      end

      def location_key
        @alocation.inject do |a, index|
          a ||= ""
          a << index.to_s
        end
      end
    end # class DocuLiner < ::Ox::Sax
  end # module Saxer
end # module Duxml