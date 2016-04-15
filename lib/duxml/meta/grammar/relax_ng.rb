require File.expand_path(File.dirname(__FILE__) + '/relax_ng/children_rule.rb')
require File.expand_path(File.dirname(__FILE__) + '/relax_ng/attributes_rule.rb')
require File.expand_path(File.dirname(__FILE__) + '/relax_ng/value_rule.rb')

module RelaxNG
  # @param *args [nil]
  # @return [Nokogiri::XML::RelaxNG] RelaxNG schema object
  def relaxng(*args)
    return args.first if args.first.is_a?(Nokogiri::XML::RelaxNG)
    cur_element = element [[:grammar, {xmlns: 'http://relaxng.org/ns/structure/1.0',
                                       datatypeLibrary: 'http://www.w3.org/2001/XMLSchema-datatypes'}],
                           [:start, {combine: 'choice'}],
                           [:ref, {name: children.first.subject}]]
    children.each do |rule|
      rule.relaxng cur_element.document.root
    end
    # TODO these are for testing only!! remove later!!!
    File.write 'test.rng', cur_element.document.to_xml
    File.write 'grammar.xml', xml.to_xml
    # TODO back to valid code

    Nokogiri::XML::RelaxNG.new cur_element.document.to_s
  end # def relaxng
end # module RelaxNG
