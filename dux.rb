require File.expand_path(File.dirname(__FILE__) + '/dux/meta')

module Dux
  @current_dux
  attr_accessor :current_dux

  def save file_name
    s = current_dux.xml_root_node.document.remove_empty_lines!.to_xml.gsub!('><', ">\n<")
    File.write file_name, s
  end

  def dux xml
    @current_dux = Meta.new xml
  end

  def load file
    xml = Nokogiri::XML(File.open file).root
    dux xml if File.exists? file
  end

  def validate file=nil
    if file.nil?
      current_dux.design.each do |node| current_dux.grammar.validate node end unless current_dux.grammar.nil?
    else
      load file
      validate
    end
    current_dux
  end
end # module Dux
