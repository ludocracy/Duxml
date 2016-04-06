require 'nokogiri'
require File.expand_path(File.dirname(__FILE__) + '/dux/meta')

module Dux
  @current_file
  @current_meta
  attr_accessor :current_file, :current_meta, :current_design

  # saves XML file with changes
  def save(file_name = current_file)
    s = cu.xml.document.remove_empty_lines!.to_xml.gsub!('><', ">\n<")
    File.write file_name, s
  end

  # links metadata to target xml
  # TODO have this method perform repairs if given metadata and xml do not have matching names/locations
  def dux(meta_xml, xml)
    @current_meta = Meta.new meta_xml
    @current_meta << xml
    @current_design = current_meta.design
  end

  # loads given file and finds metadata file e.g. '.xml_file.dux'
  # and combines them into single tree while keeping XML separated
  def load(file)
    raise Exception unless File.exists? file
    @current_file = file
    dux_meta_file_path = File.dirname(file)+"/.#{File.basename(file, '.*')}.dux"
    f = File.read(file).to_s
    xml = Nokogiri::XML(f).root
    unless File.exists?(dux_meta_file_path)
      File.new dux_meta_file_path, 'w+'
      File.write(dux_meta_file_path, Meta.new.xml)
    end
    meta_xml = Nokogiri::XML File.open(dux_meta_file_path)
    dux meta_xml, xml
  end

  # outputs validation errors in human-readable form to log file
  def log(file)
    File.write file, current_meta.history.description
  end

  # applies validation rules to XML file and updates metadata with any errors found
  def validate(file=nil)
    if file.nil?
      @current_meta.design.each do |node|
        current_meta.grammar.validate node unless node.text?
      end
    else
      load file
      validate
    end
    current_meta
  end
end # module Dux
