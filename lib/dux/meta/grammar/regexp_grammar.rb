require 'rubyXL'
require File.expand_path(File.dirname(__FILE__) + '/../grammar')

module Dux
  class Grammar
    def initialize xml_node_or_file, args={}
      xml_node = class_to_xml(xml_node_or_file)
      xml_node = xml_node[:ref] ? class_to_xml(xml_node[:ref]) : xml_node
      super xml_node, reserved: %w{regexp_rule}
    end

    def regexp_style_str_rewriter str
      s = str.gsub(/[<>\s]/, '')
      "child_rule(object, \"#{s}\")"
    end

    def class_to_xml xml_node_or_file
      if xml_node_or_file.is_a?(String) && File.exists?(xml_node_or_file)
        worksheet = RubyXL::Parser.parse(xml_node_or_file)[0]
        new_xml = super
        worksheet.each_with_index do |row, index|
          next if index == 0
          break if row[3].nil? || row[4].nil?
          statement_str = regexp_style_str_rewriter row[4].value
          new_xml << element('regexp_rule', {subject: row[3].value}, statement_str)
          #new_xml << element('regexp_rule', {subject: row[3], statement: row[5].value}) unless row[5].nil?
        end
        new_xml
      elsif xml_node_or_file.nil?
        super
      else
        xml_node_or_file.xml
      end
    end # def class_to_xml
  end # class Grammar

  class RegexpRule < Rule
    attr_reader :object

    def child_rule object, s
      @object = object
      rule_array = s.split(',').collect do |rule|
        %w(? * +).include?(rule[-1]) ? [rule[0..-2], rule[-1]] : [rule, '']
      end
      ruling = check_number(rule_array) && check_position(rule_array)
      ruling
    end

    private

    def check_number rule_array
      t_s, t_i = type_size_and_index
      case rule_array[t_i].last
        when '?' then t_s <= 1
        when '*' then t_s >= 0
        when '+' then t_s > 1
        else t_s == 1
      end
    end

    def check_position rule_array
      t_s, type_actual_position = type_size_and_index
      position_gap = type_rule_position(rule_array) - type_actual_position
      optionals = 0
      rule_array.each do |rule|
        break if object.type.match?(Regexp.new rule.first)
        optionals_size = rule.last == '*' ? rule.first.split('|').size : 1
        optionals += optionals_size if %w(* ?).include?(rule.last)
      end
      optionals < position_gap
    end

    def type_size_and_index
      siblings = object.parent.children
      type_counter = 0
      type_index = 0
      child_type_index = -1
      siblings.each_with_index do |sibling_or_self, index|
        type_index +=1 if !index.zero? && siblings[index].type != siblings[index-1].type
        if sibling_or_self.type == object.type
          child_type_index = type_index
          type_counter += 1
        end
      end
      return type_counter, child_type_index
    end # def position_and_type_size

    def type_rule_position rule_array
      rule_array.each_with_index do |rule, index|
        return index if object.type.match?(Regexp.new rule.first)
      end
    end
  end # class RegexpRule
end # module Dux