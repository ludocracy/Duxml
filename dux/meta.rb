require File.expand_path(File.dirname(__FILE__) + '/../dux/meta/history')
require File.expand_path(File.dirname(__FILE__) + '/../dux/meta/grammar.rb')

class Meta < DuxObject

  def initialize xml_node=nil, args = {}
    super class_to_xml(xml_node), reserved: %w(history grammar)
  end

  def find target
    n = target.respond_to?(:name) ? target.name : target.to_s
    last_child.each do |node|
      return node if node.name == n
    end
    nil
  end

  def history
    find_child 'history'
  end

  def grammar
    find_child 'grammar'
  end

  def design
    resolve_ref(:ref) || last_child
  end

  def class_to_xml xml_node
    xml_node = Nokogiri::XML File.open xml_node if File.exists?(xml_node.to_s)
    xml_node = xml_node.root if xml_node.respond_to?(:root)
    if (xml_node = xml_node.xml) && xml_node.name != 'meta'
      new_xml = Nokogiri::XML(%(
        <meta id="temp_id">
          <grammar/>
          <history>
            <insert id="change_0">
                <description>initial commit</description>
                <date>#{Time.now.to_s}</date>
            </insert>
        </meta>)).root
      if xml_node.name != 'design'
        design_xml = element 'design'
        design_xml << xml_node
      else
        design_xml = xml_node
      end
      new_xml << design_xml
      new_xml
    else
      xml_node
    end
  end

  private :class_to_xml
end # class Meta