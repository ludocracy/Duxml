require 'rubyXL'
require File.expand_path(File.dirname(__FILE__) + '/../grammar')

module Dux
  class Grammar
    def initialize xml_node_or_file, args={}
      xml_node = class_to_xml xml_node_or_file
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
      @cur_object = object
      rule_array = s.split(',').collect do |rule|
        %w(? * +).include?(rule[-1]) ? [rule[0..-2], rule[-1]] : [rule, '']
      end
      scanners = get_scanners rule_array
      child_stack = object.nil? ? [] : object.parent.children.clone
      result = scan scanners, child_stack
      result
    end

    private
    def get_scanners rule_array
      Struct.new 'Scanner', :match, :operator, :counter
      rule_array.collect do |rule| Struct::Scanner.new Regexp.new(rule.first), rule.last, 0 end
    end

    def any_next_type_siblings? type_pattern, child
      sibling = child.next_sibling
      until sibling.nil? do
        return true if sibling.type.match type_pattern
        sibling = sibling.next_sibling
      end
      false
    end

    def scan scanners, child_stack
      scanner = scanners.shift
      result = false
      return result if child_stack.empty? && scanners.any? do |scanner|
        %w(* ?).any? do |operator| operator != scanner[:operator] end
      end
      loop do
        child = child_stack.shift
        break if child.nil? || scanner.nil?
        if child.type.match scanner[:match] # scanner matches this child
          scanner[:counter] += 1
          if any_next_type_siblings? scanner[:match], child # is not last of type group
           redo
          else # is last of type group
           result = case scanner[:operator] # so done counting and can compare type count to operator
             when '?' then scanner[:counter] <= 1
             when '*' then scanner[:counter] >= 0
             when '+' then scanner[:counter] >= 1
             else scanner[:counter] == 1
           end
          end # if next_type == child.type
        else # scanner does not match this child
          case scanner[:operator]
            when '?', '*' # optional scanner so try next one on same child
              scanner = scanners.shift
              child_stack.unshift child
              result = true # store as last result
           else result = false # else, this scanner will report false
          end
        end # if child.type.match scanner[:match]
        break if child.id == @cur_object.id && scanners.empty? # loop do
      end
      result # default return value should be true?
    end # def scan
  end # class RegexpRule
end # module Dux