require File.expand_path(File.dirname(__FILE__) + '/pattern_maker.rb')
require File.expand_path(File.dirname(__FILE__) + '/grammar/rule/children_rule')
require File.expand_path(File.dirname(__FILE__) + '/grammar/rule/attributes_rule')
require File.expand_path(File.dirname(__FILE__) + '/grammar/rule/value_rule')
require File.expand_path(File.dirname(__FILE__) + '/grammar/rule/content_rule')
require File.expand_path(File.dirname(__FILE__) + '/grammar/relax_ng')
require 'rubyXL'

module Duxml
  # contains Duxml::Rules and can apply them by validating XML or qualifying user input
  # reporting Duxml::Errors to History as needed
  class Grammar < Object
    include PatternMaker
    include RelaxNG

    # @param xml_node_or_file [Nokogiri::XML::Node, String] can initialize from XML node if reading from file
    #   or from XML file or spreadsheet
    def initialize(xml_node_or_file=nil)
      if xml_node_or_file.is_a?(String) && File.exists?(xml_node_or_file)
        if %w(.xlsx .csv).include?(File.extname xml_node_or_file)
          class_to_xml nil
          super()
          sheet_to_xml xml_node_or_file
        else
          super xml_node_or_file
        end
      else
        super xml_node_or_file
      end
    end # def initialize

    # @return [Boolean] whether or not any rules have been defined yet in this grammar
    def defined?
      has_children?
    end

    # @return [String] lists XML schema and content rules in order of precedence
    def description
    "grammar follows: \n" +
        children.collect do |change_or_error|
          change_or_error.description
        end.join("\n")
    end

    # @param node [Duxml::Object] applies grammar rules to all relationships of the given object
    # @result [Boolean] whether all rules qualified
    def validate(node)
      rels = get_relationships(node)
      results = rels.collect do |rel|
        qualify rel
      end
      any_disqualified = results.any? do |qualified| !qualified end
      !any_disqualified
    end # def validate

    # @param change_or_pattern [Duxml::Change, Duxml::Pattern] applies applicable rule type and subject
    #   to given change_or_pattern and generates errors when disqualified
    # @return [Boolean] false if any rule disqualifies; true if they all pass
    def qualify(change_or_pattern)
      rules = get_rule(change_or_pattern)

      # define behaviors for when there are no rules applying to a given pattern
      if rules.empty?
        return true if change_or_pattern.respond_to?(:new_content)
        return true if change_or_pattern.respond_to?(:value)
        report :validate_error, change_or_pattern
        return false
      end
      results = rules.collect do |rule|
        rule.qualify change_or_pattern
      end
      !results.any? do |qualified| !qualified end
    end # def qualify

    private

    # @param change_or_pattern [Duxml::Change, Duxml::Pattern] change or pattern to be qualified
    # @return [Array[Duxml::Rule]] rules that match the pattern type (e.g. :change_content => :content_rule)
    #   and subject (e.g. change_or_pattern.subject.type => 'blobs' && rule.subject => 'blobs')
    def get_rule(change_or_pattern)
      children.select do |child| child.applies_to?(change_or_pattern) end
    end # def get_rules

    # @param spreadsheet []
    def sheet_to_xml(spreadsheet)
      worksheet = RubyXL::Parser.parse(spreadsheet)[0]
      attr_val_rule_hash = {}
      worksheet.each_with_index do |row, index|
        next if index == 0
        break if row[3].nil? || row[4].nil?
        element_name = row[3].value
        statement_str = row[4].value
        ary = [Duxml::ChildrenRule.new(element_name, statement_str)]
        attribute_rules = row[5].value.split(/\n/)
        attribute_rules.each_with_index do |rule, i| # looping through attribute rules
          next if i == 0 or rule.empty?
          attr_name, value_expr, attr_req = *rule.split
          ary << Duxml::AttributesRule.new(element_name, attr_name, attr_req)
          unless attr_val_rule_hash[attr_name]
            ary << Duxml::ValueRule.new(attr_name, value_expr)
            attr_val_rule_hash[attr_name] = true
          end
        end
        ary.each do |rule| self << rule; @xml << rule.xml end
      end # worksheet.each_with_index
    end # def sheet_to_xml
  end # class Grammar
end # module Duxml