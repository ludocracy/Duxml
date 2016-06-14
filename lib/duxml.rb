# Copyright (c) 2016 Freescale Semiconductor Inc.

require File.expand_path(File.dirname(__FILE__) + '/duxml/saxer')
require File.expand_path(File.dirname(__FILE__) + '/duxml/meta')

module Duxml
  DITA_GRAMMAR = File.expand_path(File.dirname(__FILE__) + '/../xml/dita_grammar.xml')
  include Saxer
  include Meta

  # path to XML file
  @file
  # current document
  @doc
  # meta data document
  @meta

  attr_reader :meta, :file, :doc

  # @param file [String, Doc] loads or creates given file or document and finds or creates corresponding metadata file e.g. '.xml_file.duxml'
  # @param grammar_path [nil, String, Duxml::Grammar] optional - provide an external grammar file or object
  # @return [Duxml::Meta] combined Object tree from metadata root (metadata and content's XML documents are kept separate)
  def load(_file, grammar_path=nil)
    grammar_path = DITA_GRAMMAR if grammar_path == :dita
    if _file.is_a?(String) and File.exists?(_file)
      @file = _file
    else
      @file = "#{(_file.respond_to?(:name) ? _file.name : _file.class.to_s) + _file.object_id.to_s}"
      File.write file, ''
    end

    set_metadata!(grammar_path)
    set_doc!
  end # def load

  # @param file [String] creates new XML file at given path
  # @param content [Doc, Element] XML content with which to initialize new file
  def create(file, content=nil)
    File.write(file, content.to_s)
    @doc = content.is_a?(Doc) ? content : Doc.new
  end

  # @param file [String] saves current content XML to given file path (Duxml@file by default)
  def save(file)
    meta_path = Meta.meta_path(file)
    unless File.exists?(meta_path)
      File.new meta_path, 'w+'
      File.write(meta_path, Meta.xml)
    end
  end

  # @param file [String] output file path for logging human-readable validation error messages
  def log(file)
    File.write(file, meta.history.description)
  end

  # @param *Args [*several_variants] @see #load
  # @return [Boolean] whether file passed validation
  def validate(*args)
    load(*args) unless args.empty?
    raise Exception, "grammar not defined!" unless meta.grammar.defined?
    raise Exception, "document not loaded!" unless doc.root
    results = []
    doc.root.traverse do |n| results << meta.grammar.validate(n) unless n.is_a?(String) end
    !results.any? do |r| !r end
  end # def validate

  # @return [Nokogiri::XML::RelaxNG] current metadata's grammar as a relaxng file
  def relaxng
    #meta.grammar.relaxng
  end

  private

  # @return [Doc] @doc is set to either file given by user or new Doc
  def set_doc!
    @doc ||= if file.nil?
               f = Doc.new
               f.add_observer meta.history
               f
             else
               f = File.open file
               sax(f, meta.history)
             end
  end

  # @return [MetaClass] @meta is set to either file extrapolated from path of XML-content file or new MetaClass
  def set_metadata!(grammar_path=nil)
    meta_path = Meta.meta_path(file)
    if file and File.exists?(meta_path)
      @meta = sax(File.open(meta_path)).root
      meta.grammar=grammar_path unless grammar_path.nil? or meta.grammar.defined?
    else
      @meta = MetaClass.new(grammar_path)
    end
    meta
  end
end # module Duxml
