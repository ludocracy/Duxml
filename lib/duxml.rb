require 'nokogiri'
require File.expand_path(File.dirname(__FILE__) + '/duxml/meta')

module Duxml
  # contains file name of current XML file
  @current_file
  # points to current file's metadata
  @current_meta
  # points to current file's object tree (branch of meta at this point)
  @current_design

  attr_accessor :current_file, :current_meta, :current_design

  # @param file [String] saves current content XML to given file path (Duxml@current_file by default)
  def save(file = current_file)
    s = current_design.xml.document.remove_empty_lines!.to_xml.gsub!('><', ">\n<")
    File.write file, s
    File.write get_meta_file, current_meta.xml.to_xml.gsub!('><', ">\n<")
  end

  def get_meta_file
    File.dirname(current_file)+"/.#{File.basename(current_file, '.*')}.duxml"
  end

  # @param meta_xml [Nokogiri::XML::Node] metadata XML
  # @param content_xml [Nokogiri::XML::Node] content XML
  # @return [Duxml::Meta] combined object tree including metadata
  def dux(meta_xml, content_xml)
    @current_meta = Meta.new meta_xml
    @current_meta << content_xml
    @current_design = current_meta.design
    current_meta
  end

  # @param file [String] loads given file and finds or creates corresponding metadata file e.g. '.xml_file.duxml'
  # @param grammar [nil, String, Duxml::Grammar] optional - provide an external grammar file or object
  # @return [Duxml::Meta] combined Object tree from metadata root (metadata and content's XML documents are kept separate)
  def load(file, grammar=nil)
    raise Exception unless File.exists? file
    @current_file = file
    dux_meta_file_path = get_meta_file
    f = File.read(current_file).to_s
    xml = Nokogiri::XML(f).root
    unless File.exists?(dux_meta_file_path)
      File.new dux_meta_file_path, 'w+'
      File.write(dux_meta_file_path, Meta.new.xml.to_xml)
    end
    meta_xml = Nokogiri::XML(File.open(dux_meta_file_path)).root
    dux meta_xml, xml
  end # def load

  # @param file [String] path to file to be used as or converted to Duxml::Grammar
  # @return [Duxml::Grammar] grammar, now attached to @current_meta
  def grammar(file)
    @current_meta.grammar = file
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
