# Copyright (c) 2016 Freescale Semiconductor Inc.

require 'rubyXL'

module Duxml
  # contains helper methods to convert spreadsheet of DTD rules into Duxml::Rules
  module Spreadsheet
    private
  # @param path [String] spreadsheet file
    def self.sheet_to_xml(path)
      worksheet = RubyXL::Parser.parse(path)[0]
      attr_val_rule_hash = {}
      g = GrammarClass.new
      worksheet.each_with_index do |row, index|
        next if index == 0
        break if row[3].nil? || row[4].nil?
        element_name = row[3].value
        statement_str = row[4].value
        g << ChildrenRuleClass.new(element_name, statement_str)
        attribute_rules = row[5].value.split(/\n/)
        attribute_rules.each_with_index do |rule, i|
          next if i == 0 or rule.empty?
          attr_name, value_expr, attr_req = *rule.split
          next if [attr_name, value_expr, attr_req].any? do |s| s.empty? or s.match(/\w/).nil? end
          g << AttrsRuleClass.new(element_name, attr_name, attr_req)
          unless attr_val_rule_hash[attr_name]
            g << ValueRuleClass.new(attr_name, value_expr)
            attr_val_rule_hash[attr_name] = true
          end
        end # attribute_rules.each_with_index
      end # worksheet.each_with_index
      g
    end # def sheet_to_xml(path)
  end # module Spreadsheet
end # module Duxml