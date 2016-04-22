require File.expand_path(File.dirname(__FILE__) + '/doc/element')

module Duxml
  class Doc < ::Ox::Document
    include ElementGuts
    def initialize(prolog={})
      super(prolog)
      @nodes = NodeSet.new(self)
    end
  end # class Document < Element
end