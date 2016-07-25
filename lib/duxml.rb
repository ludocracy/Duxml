# Copyright (c) 2016 Freescale Semiconductor Inc.

require File.expand_path(File.dirname(__FILE__) + '/duxml/saxer')

module Duxml
  include Saxer

  # @param _file [String] loads XML file from given path and finds or creates corresponding metadata file e.g. '.xml_file.duxml'
  # @param grammar_path [nil, String, Duxml::Grammar] optional - provide an external grammar file or object
  # @return [Doc] XML document as Ruby object
  def load(_file, grammar_path=nil)
    meta_path = Meta.meta_path(_file)

    if File.exists?(meta_path)
      meta = sax(File.open meta_path).root
      meta.grammar=grammar_path unless grammar_path.nil? or meta.grammar.defined?
    else
      meta = MetaClass.new(grammar_path)
    end

    if File.exists?(_file)
      doc = sax(_file, meta.history)
    else
      doc = Doc.new
      doc.add_observer meta.history
      doc.path = _file
    end

    doc.meta = meta
    doc
  end # def load

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

  # @param *Args [String, Doc] if string then path to load Doc, else Doc to validate
  # @return [Boolean] whether file passed validation
  def validate(path_or_doc, options={})
    doc = path_or_doc.is_a?(String) ? load(path_or_doc) : path_or_doc
    raise Exception, "grammar not defined!" unless meta.grammar.defined?
    raise Exception, "document not loaded!" unless doc.root
    results = []
    doc.root.traverse do |n| results << meta.grammar.validate(n) unless n.is_a?(String) end
    puts(doc.history.description) if options[:verbose]
    !results.any? do |r| !r end
  end # def validate
end # module Duxml
