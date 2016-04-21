require File.expand_path(File.dirname(__FILE__) + '/relax_ng/children_rule.rb')
require File.expand_path(File.dirname(__FILE__) + '/relax_ng/attributes_rule.rb')
require File.expand_path(File.dirname(__FILE__) + '/relax_ng/value_rule.rb')

module RelaxNG
  # @param output_path [String] optional, output path for .rng file
  # @return [Nokogiri::XML::RelaxNG] RelaxNG schema object
  def relaxng(output_path=nil)
    cur_element = element [[:grammar, {xmlns: 'http://relaxng.org/ns/structure/1.0',
                                       datatypeLibrary: 'http://www.w3.org/2001/XMLSchema-datatypes'}],
                           [:start, {combine: 'choice'}],
                           [:ref, {name: children.first.subject}]]
    children.each do |rule|
      rule.relaxng cur_element.document.root
    end

    # fill in empty doc definitions to make them legal
    element_defs = cur_element.document.css('doc')
    element_defs.each do |element_def|
      element_def << '<empty/>' unless element_def.element_children.any?
    end
    File.write output_path , cur_element.document.to_xml if output_path
    Nokogiri::XML::RelaxNG.new cur_element.document.to_xml
  end # def relaxng
end # module RelaxNG
