require 'nokogiri'

class Object
  # shortcut for turning any string-like object or class into XML
  # extension of Module::Object that can turn Ruby objects into Nokogiri::XML objects
  # returned object is a Nokogiri::XML::Element, not a Nokogiri::XML::Document
  def xml
    return Nokogiri::XML(File.read self).root if File.exists?(self.to_s)
    self.is_a?(Nokogiri::XML::Element) ? self : Nokogiri::XML(self.to_s).root
  end

  # shortcut for turning object's class name into snake_case string
  def simple_class
    str = self.class.to_s.split('::').last
    str.split(//).collect do |char|
      if char == '_'
        '-'
      else
        char == char.upcase ? "_#{char.downcase!}" : char.downcase
      end
    end.join[1..-1]
  end
end