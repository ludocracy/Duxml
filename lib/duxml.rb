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
    s = cu.xml.document.remove_empty_lines!.to_xml.gsub!('><', ">\n<")
    File.write file_name, s
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
  # @return [Duxml::Meta] combined Object tree from metadata root (metadata and content's XML documents are kept separate)
  def load(file)
    raise Exception unless File.exists? file
    current_file = file
    dux_meta_file_path = File.dirname(file)+"/.#{File.basename(file, '.*')}.duxml"
    f = File.read(file).to_s
    xml = Nokogiri::XML(f).root
    unless File.exists?(dux_meta_file_path)
      File.new dux_meta_file_path, 'w+'
      File.write(dux_meta_file_path, Meta.new.xml)
    end
    meta_xml = Nokogiri::XML File.open(dux_meta_file_path)
    dux meta_xml, xml
  end # def load

  # @param file [String] output file path for logging human-readable validation error messages
  def log(file)
    File.write file, current_meta.history.description
  end

  # @param file [String] path of XML file to be validated
  # @return metadata [Duxml::Meta] which then contains any validation errors
  def validate(file=nil)
    if file.nil?
      current_meta.design.each do |node|
        current_meta.grammar.validate node unless node.text?
      end
    else
      load file
      validate
    end
    current_meta
  end # def validate

  # @return [Nokogiri::XML::RelaxNG] current metadata's grammar as a relaxng file
  def relaxng
    current_meta.grammar.relaxng
  end
end # module Duxml
