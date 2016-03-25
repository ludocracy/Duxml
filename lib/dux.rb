require File.expand_path(File.dirname(__FILE__) + '/dux/meta')

module Dux
  @current_dux
  attr_accessor :current_dux

  def save file_name
    s = current_dux.xml_root_node.document.remove_empty_lines!.to_xml.gsub!('><', ">\n<")
    File.write file_name, s
  end

  def dux meta, xml
    combined_xml = meta.root << xml
    @current_dux = Meta.new combined_xml
  end

  def load file
    raise Exception unless File.exists? file
    dux_meta_file_path = File.dirname(file)+"/.#{File.basename(file, '.*')}.dux"
    xml = Nokogiri::XML(File.open file).root
    unless File.exists?(dux_meta_file_path)
      File.new dux_meta_file_path, 'w+'
      File.write(dux_meta_file_path, Meta.new.xml)
    end
    meta_xml = Nokogiri::XML File.open(dux_meta_file_path)
    dux meta_xml, xml
  end

  def log file
    File.write file, current_dux.history.description
  end

  def validate file=nil
    if file.nil?
      current_dux.design.each do |node|
        current_dux.grammar.validate node
      end
    else
      load file
      validate
    end
    current_dux.history.each do |pattern|
      # TODO get descriptions working for all error types and test log output
      #STDERR.puts pattern.description if pattern.type == 'validate_error'
    end
    current_dux
  end
end # module Dux
