require File.expand_path(File.dirname(__FILE__) + '/doc/saxer')
require File.expand_path(File.dirname(__FILE__) + '/doc/meta')

module Duxml
  class Doc < ::Ox::Document
    include Saxer

    @meta

    def initialize(path, prolog={})
      raise Exception unless File.exists?(path)
      super(prolog)
      @meta = get_meta_data path
      history.add_observer grammar
      @io = File.open path
      self << sax(self)
    end

    def grammar
      @meta.nodes.first
    end

    def history
      @meta.nodes.last
    end

    private

    def get_meta_data(path)
      meta_path = File.dirname(path)+"/.#{File.basename(path)}.duxml"
      if File.exists?(meta_path)
        m = Ox.parse File.read meta_path
      else
        m = Meta.xml
        File.write(meta_path, m)
      end
      m
    end
  end # class Document < Element
end