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

    # hash of all unique-id elements within document; gets initialized as each is searched for
    @id_hash

    attr_reader :meta, :path, :id_hash

    def initialize(prolog={})
      super(prolog)
      self[:version] ||= '1.0'
      @id_hash = {}
      @meta = MetaClass.new
      @nodes = NodeSet.new(self)
      add_observer meta.history
    end

    # @param _path [String] assigns file path to document, creating it if it does not already exist along with metadata file
    def path=(_path)
      @path = _path
      set_meta _path unless path
      unless File.exists?(path)
        write_to(path)
      end
    end

    # @return [String] summary of XML document as Ruby object and description of root element
    def to_s
      "#<#{self.class.to_s} @object_id='#{object_id}' @root='#{root.nil? ? '' : root.description}'>"
    end

    # @param path_or_obj [String, MetaClass] metadata object itself or path of metadata for this file; if none given, saves existing metadata to file using @path
    # @return [Doc] self
    def set_meta(path_or_obj=nil)
      @meta = case path_or_obj
                when MetaClass, Element then path_or_obj
                when String && File.exists?(path_or_obj)
                  Ox.parse_obj(path_or_obj)
                else
                  File.write(Meta.meta_path(path), Ox.dump(meta)) if path
                  meta
              end
      self
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

    # @param path [String] document's file path
    # @return [Doc] returns self after writing contents to file
    def write_to(path)
      s = attributes.collect do |k, v| %( #{k}="#{v}") end.join
      File.write(path, %(<?xml #{s}?>\n) + root.to_s)
      x = meta.xml
      File.write(Meta.meta_path(path), meta.xml.to_s)
      self
    end

    def <<(obj)
      super(obj)
      obj.set_doc! self
      self
    end

    # @param id [String, Symbol] document-unique id attribute value
    # @return [Element, NilClass] found element or nil if not found
    def find_by_id(id)
      id_str = id.to_s
      return @id_hash[id_str] if @id_hash[id_str]
      root.traverse do |node|
        if node.respond_to?(:nodes) and node[:id] == id_str
          return @id_hash[id_str] = node
        end
      end
      nil
    end
  end # class Document < Element
end

Hash