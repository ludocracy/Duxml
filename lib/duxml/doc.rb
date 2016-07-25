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

    attr_accessor :path
    attr_reader :meta

    def initialize(prolog={})
      super(prolog)
      self[:version] ||= '1.0'
      @meta = MetaClass.new
      @nodes = NodeSet.new(self)
      add_observer meta.history
    end

    def write_to(path)
      s = attributes.collect do |k, v| %( #{k}="#{v}") end.join
      %(<?xml #{s}?>)+nodes.first.to_s
      File.write(path, s)
      self
    end

    def to_s
      "#<#{self.class.to_s} @object_id='#{object_id}' @root='#{root.nil? ? '' : root.description}'>"
    end

    def grammar
      meta.grammar
    end

    def grammar=(grammar_or_file)
      meta.grammar = grammar_or_file
    end

    def history
      meta.history
    end

    def description
      'document'
    end
  end # class Document < Element
end

Hash