require File.expand_path(File.dirname(__FILE__) + '/doc/element')

module Duxml
  class Doc < ::Ox::Document
    include ElementGuts
    def initialize(prolog={})
      super(prolog)
      self[:version] ||= '1.0'
      @nodes = NodeSet.new(self)
    end

    def to_s
      s = attributes.collect do |k, v| %( #{k}="#{v}") end.join
      %(<?xml #{s}?>)+nodes.first.to_s
    end
  end # class Document < Element
end