require File.expand_path(File.dirname(__FILE__) + '/grammar/pattern/child_pattern')
require File.expand_path(File.dirname(__FILE__) + '/grammar/pattern/content_pattern')
require File.expand_path(File.dirname(__FILE__) + '/grammar/pattern/attr_name_pattern')
require File.expand_path(File.dirname(__FILE__) + '/grammar/pattern/attr_val_pattern')
require File.expand_path(File.dirname(__FILE__) + '/grammar/rule/children_rule')
require File.expand_path(File.dirname(__FILE__) + '/grammar/rule/attributes_rule')
require File.expand_path(File.dirname(__FILE__) + '/grammar/rule/value_rule')
require File.expand_path(File.dirname(__FILE__) + '/grammar/rule/content_rule')
require 'rubyXL'

module Duxml
  # contains Duxml::Rules and can apply them by validating XML or qualifying user input
  # reporting Duxml::Errors to History as needed
  class Grammar < Object
    # Duxml::Grammar can be initialized from XML Element or
    # if given no arguments,
    def initialize(xml_node_or_file=nil)
      if xml_node_or_file.is_a?(String) && File.exists?(xml_node_or_file) &&
          %w(.xlsx .csv).include?(File.extname xml_node_or_file)
        class_to_xml nil
        super()
        sheet_to_xml xml_node_or_file
      else
        class_to_xml xml_node_or_file
        super xml[:ref]
      end
    end # def initialize

    # applies grammar rules to all relationships of the given object
    def validate(comp)
      rels = []
      if comp.children.any? do |child| !child.text? end
        comp.children.each do |child|
          rels << Duxml::ChildPattern.new(comp, child)
        end
      elsif comp.children.any?
        rels << Duxml::ContentPattern.new(comp, comp.content)
      else
        rels << Duxml::ChildPattern.new(comp)
      end
      comp.attributes.each do |k, v|
        rels << Duxml::AttrNamePattern.new(comp, k)
        rels << Duxml::AttrValPattern.new(comp, k)
      end
      rels.collect do |rel| qualify rel end.any? do |result| !result end
    end # def validate

    # lists XML schema and content rules in order of precedence
    def description
      "grammar follows: \n" +
          children.collect do |change_or_error|
            change_or_error.description
          end.join("\n")
    end

    # applies applicable rule type and subject to a given change or pattern and generates errors when disqualified
    def qualify(change_or_pattern)
      rules = get_rules(change_or_pattern.simple_class)
      rules.each do |rule|
        subj = change_or_pattern.subject meta
        subj = subj.type if subj.respond_to?(:type)
        if subj && rule[:subject] == subj
          return rule.qualify change_or_pattern
        end
      end
      true
    end # def qualify

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
    end

    private

    def sheet_to_xml(spreadsheet)
      worksheet = RubyXL::Parser.parse(spreadsheet)[0]
      worksheet.each_with_index do |row, index|
        next if index == 0
        break if row[3].nil? || row[4].nil?
        element_name = row[3].value
        statement_str = row[4].value
        ary = [Duxml::ChildrenRule.new(element_name, statement_str)]
        row[5].value.split(/\n/).each do |rule| # looping through attribute rules
          next if rule.empty?
          attr_name, value_expr, attr_req = *rule.split
          ary << Duxml::AttributesRule.new(element_name, attr_name, attr_req)
          ary << Duxml::ValueRule.new(element_name, attr_name, value_expr)
        end
        ary.each do |rule| self << rule; @xml << rule.xml end
      end # worksheet.each_with_index
    end # def sheet_to_xml

    def get_rules(type)
      rule_types = case type
                      when 'new_content', 'change_content', 'content_pattern' then
                        :content_rule
                      when 'new_attribute'
                        [:attributes_rule, :value_rule]
                      when 'attr_name_pattern'
                        :attributes_rule
                      when 'change_attribute', 'attr_val_pattern' then
                        :value_rule
                      when 'add', 'remove', 'child_pattern' then
                        :children_rule
                      else # should not happen
                   end
      find_children *rule_types
    end # def get_rules
  end # class Grammar
end # module Duxml