# Copyright (c) 2016 Freescale Semiconductor Inc.

require File.expand_path(File.dirname(__FILE__) + '/doc')

module Duxml
  module Saxer
    @io

    attr_accessor :io
    # @param path_or_xml [String] path of file to parse or XML as String
    # @return [Doc, Element] finished document with each Element's line and column info added
    def sax(path_or_xml, obs=nil)
      doc_or_no = File.exists?(path_or_xml)
      io = doc_or_no ? File.open(path_or_xml): path_or_xml
      saxer = DocuLiner.new(Duxml::Doc.new, obs)
      Ox.sax_parse(saxer, io, {convert_special: true, symbolize: false})
      doc = saxer.cursor
      return doc.root unless doc_or_no
      doc.add_observer obs if obs and doc.count_observers < 1
      doc.path = path_or_xml
      doc
    end

    alias_method :parse, :sax

    class DocuLiner < ::Ox::Sax
      # @param doc [Ox::Document] document that is being constructed as XML is parsed
      # @param _observer [Object] object that will observe this document's content
      def initialize(doc, _observer)
        @cursor_stack = [doc]
        @line = 0
        @column = 0
        @observer = _observer
      end

      attr_reader :line, :column, :observer

      def cursor
        cursor_stack.last
      end

      attr_accessor :cursor_stack

      def start_element(name)
        cursor.nodes.insert(-1, Duxml::Element.new(name, line, column))
        cursor_stack << cursor.nodes.last.set_doc!(cursor_stack.first)
      end

      def attr(name, val)
        cursor[name] = val
      end

      def text(str)
        cursor.nodes.insert(-1, str)
      end

      def end_element(name)
        cursor.add_observer(observer) if observer
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