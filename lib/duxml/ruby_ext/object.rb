require 'nokogiri'

class Class
  # shortcut for turning object's class name into snake_case string
  def simple_class
    str = to_s.split('::').last
    str.gsub!(/[A-Z_]/) do |char|
      case char
        when /[A-Z]/ then "_#{char.downcase!}"
        when '_' then '-'
      end
    end
    @simple_class = str[1..-1]
  end
end

class Object
  # shortcut for turning any string-like object or class into XML
  # extension of Module::Object that can turn Ruby objects into Nokogiri::XML objects
  # returned object is a Nokogiri::XML::Element, not a Nokogiri::XML::Document
  def xml
    return Nokogiri::XML(File.read self.to_s).root if File.exists?(self.to_s)
    self.is_a?(Nokogiri::XML::Element) ? self : Nokogiri::XML(self.to_s).root
  end

  def simple_class
    self.class.simple_class
  end

  private def new_id
    self.simple_class+object_id.to_s
  end
end