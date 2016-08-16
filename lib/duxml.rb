# Copyright (c) 2016 Freescale Semiconductor Inc.

require File.expand_path(File.dirname(__FILE__) + '/duxml/saxer')

module Duxml
  include Saxer

  # most recently processed document - default location for validated documents that are not loaded explicitly
  @doc

  attr_reader :doc

  # @param _file [String] loads XML file from given path and finds or creates corresponding metadata file e.g. '.xml_file.duxml'
  # @param grammar_path [nil, String, Duxml::Grammar] optional - provide an external grammar file or object
  # @return [Doc] XML document as Ruby object
  def load(_file, grammar_path=nil)
    meta_path = Meta.meta_path(_file)

    if File.exists?(meta_path)
      meta = sax(File.open meta_path).root
      meta.grammar = grammar_path unless grammar_path.nil? or meta.grammar.defined?
    else
      meta = MetaClass.new(grammar_path)
    end

    if File.exists?(_file)
      @doc = sax(_file, meta.history)
    else
      @doc = Doc.new
      @doc.path = _file

      doc.add_observer meta.history if doc.count_observers < 1
    end
    doc.set_meta meta
  end # def load

  # @param file [String] saves current content XML to given file path
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
  # @param options [Hash, Symbol] currently just supports suppression of console output of results with :quiet
  # @return [Boolean] whether file passed validation
  def validate(path_or_doc, options={})
    doc = path_or_doc.is_a?(Doc) ? path_or_doc : load(path_or_doc)
    unless doc.grammar.defined?
      raise Exception, "grammar not defined!" unless options[:grammar]
      doc.grammar = options[:grammar]
    end
    raise Exception, "XML document has no root element!" unless doc.root
    results = []
    doc.root.traverse do |n| results << doc.grammar.validate(n) unless n.is_a?(String) end
    puts(doc.history.description) unless options[:quiet]
    !results.any? do |r| !r end
  end # def validate

  private
  # @param g_path [String, GrammarClass] grammar to associate with @doc, which must be set to a Doc and not nil
  def associate_grammar(g_path)
    doc.grammar = g_path if g_path
  end

  def find_meta

  end
end # module Duxml
