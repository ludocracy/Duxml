require 'ox'
require File.expand_path(File.dirname(__FILE__) + '/duxml/ox_ext/duxml_doc')

module Duxml

  # path to XML file
  @file
  # current document
  @doc
  # node path, line number hash
  @node_hash
  # meta data document
  @meta

  attr_reader :meta, :file, :doc, :node_hash

  # @param file [String] loads given file and finds or creates corresponding metadata file e.g. '.xml_file.duxml'
  # @param grammar [nil, String, Duxml::Grammar] optional - provide an external grammar file or object
  # @return [Duxml::Meta] combined Object tree from metadata root (metadata and content's XML documents are kept separate)
  def load(file, grammar=nil)
    raise Exception unless File.exists? file
    @file = file
    dux_meta_file_path = get_meta_file
    io = StringIO.new(File.read(file))

    handler = NodeHasher.new
    xml_doc = Ox.sax_parse(handler, io, {convert_special: true, symbolize: false})
    @node_hash = handler.node_hash
    unless File.exists?(dux_meta_file_path)
      File.new dux_meta_file_path, 'w+'
      File.write(dux_meta_file_path, xml(Meta))
    end
    meta_xml = Ox.parse(File.open(dux_meta_file_path)).root
    @meta, @doc = meta_xml, xml_doc
  end # def load

  # @param file [String] saves current content XML to given file path (Duxml@file by default)
  def save(path=file)
    s = Ox.dump(doc)
    File.write path, s
    File.write(get_meta_file, xml(doc))
  end

  def get_meta_file
    File.dirname(file)+"/.#{File.basename(file, '.*')}.duxml"
  end

  # @param file [String] output file path for logging human-readable validation error messages
  def log(file)
    File.write file, current_meta.history.description
  end

  # @param file [String] path of XML file to be validated
  # @return [Boolean] whether file passed validation
  def validate(file=nil)
    load file if file
    current_meta.grammar &&= current_meta.grammar[:ref] unless current_meta.grammar.defined?
    results = current_meta.design.collect do |node|
      node.text? || current_meta.grammar.validate(node)
    end
    result = !results.any? do |val| !val end
    File.write get_meta_file, current_meta.xml.to_xml unless result
    result
  end # def validate

  # @return [Nokogiri::XML::RelaxNG] current metadata's grammar as a relaxng file
  def relaxng
    current_meta.grammar.relaxng
  end
end # module Duxml
