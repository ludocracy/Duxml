# Copyright (c) 2016 Freescale Semiconductor Inc.

require File.expand_path(File.dirname(__FILE__) + '/doc/element')

module Duxml
  class Doc < ::Ox::Document
    include ElementGuts
    def initialize(prolog={})
      super(prolog)
      self[:version] ||= '1.0'
      @nodes = NodeSet.new(self)
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
  end # class Document < Element
end