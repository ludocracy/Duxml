require File.expand_path(File.dirname(__FILE__) + '/relax_ng/children_rule')
require File.expand_path(File.dirname(__FILE__) + '/relax_ng/attrs_rule')
require File.expand_path(File.dirname(__FILE__) + '/relax_ng/value_rule')
require File.expand_path(File.dirname(__FILE__) + '/../../doc')

module Duxml
  module RelaxNG
    include Duxml
    # @param output_path [String] optional, output path for .rng file
    # @return [Nokogiri::XML::RelaxNG] RelaxNG schema object
    def relaxng(output_path=nil)
      doc = Doc.new
      doc << Element.new('grammar')
      doc.grammar[:xmlns] = 'http://relaxng.org/ns/structure/1.0'
      doc.grammar[:datatypeLibrary] = 'http://www.w3.org/2001/XMLSchema-datatypes'
      start = Element.new('start')
      start[:combine] = 'choice'
      ref = Element.new('ref')
      ref[:name] = rules.first.subject
      start << ref
      doc.grammar << start
      rules.each do |rule|
        rule.relaxng doc.grammar
      end

      # fill in empty doc definitions to make them legal
      element_defs = doc.grammar.Define.collect do |d|
        d.element if d.nodes.first.name == 'element' and d.element.nodes.empty?
      end.compact
      element_defs.each do |element_def|
        element_def << Element.new('empty')
      end
      doc.write_to output_path if output_path
      doc
    end # def relaxng
  end # module RelaxNG
end # module Duxml