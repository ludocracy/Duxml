# Copyright (c) 2016 Freescale Semiconductor Inc.

require File.expand_path(File.dirname(__FILE__) + '/doc/element')
require File.expand_path(File.dirname(__FILE__) + '/meta')

module Duxml
  class Doc < ::Ox::Document
    include ElementGuts

    # path of file where this Doc is saved to
    @path

    # meta data for this Doc; contains reference to grammar if it exists and history
    @meta

    attr_reader :meta, :path

    def initialize(prolog={})
      super(prolog)
      self[:version] ||= '1.0'
      @meta = MetaClass.new
      @nodes = NodeSet.new(self)
      add_observer meta.history
    end

    # assigns file path to document
    def path=(_path)
      path = _path
      # handle case where path already exists?
    end

    # do we need this??
    def write_to(path)
      s = attributes.collect do |k, v| %( #{k}="#{v}") end.join
      %(<?xml #{s}?>)+nodes.first.to_s
      File.write(path, s)
      self
    end

    # @return [String] summary of XML document as Ruby object and description of root element
    def to_s
      "#<#{self.class.to_s} @object_id='#{object_id}' @root='#{root.nil? ? '' : root.description}'>"
    end

    # shortcut method @see Meta#grammar
    def grammar
      meta.grammar
    end

    # shortcut method @see Meta#grammar=
    def grammar=(grammar_or_file)
      meta.grammar = grammar_or_file
    end

    # shortcut method @see Meta#history
    def history
      meta.history
    end

    # @return [String] one word description of what this object is: 'document'
    def description
      'document'
    end
  end # class Document < Element
end

Hash