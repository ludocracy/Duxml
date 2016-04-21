require File.expand_path(File.dirname(__FILE__) + '/doc/element')

module Duxml
  class Doc < ::Ox::Document
    include Duxml
  end # class Document < Element
end