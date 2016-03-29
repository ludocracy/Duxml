require File.expand_path(File.dirname(__FILE__) + '/../rule')

module Dux
  class ChildRule < Rule
    def initialize xml_node, args={}
      xml_node.content = xml_node[:statement].to_s.gsub(/[<>]/, '\b').gsub(/\s/, '')
      xml_node.remove_attribute 'statement'
      super xml_node, args
    end

    def qualify change_or_pattern
      @cur_object = change_or_pattern.object meta
      rule_array = content.split(',').collect do |rule|
        %w(? * +).include?(rule[-1]) ? [rule[0..-2], rule[-1]] : [rule, '']
      end
      scanners = get_scanners rule_array
      super change_or_pattern unless pass scanners
    end

    def description
      %(#{namme} which states that children of #{subject.type} must match #{statement})
    end

    private

    def get_scanners rule_array
      Struct.new 'Scanner', :match, :operator, :counter
      rule_array.collect do |rule|
        Struct::Scanner.new Regexp.new(dtd_to_regexp rule.first), rule.last, 0
      end
    end

    def dtd_to_regexp child_pattern
      child_pattern.gsub(/<>/, '').gsub('#PCDATA', 'p_c_data')
    end

    def any_next_type_siblings? type_pattern, child
      sibling = child.next_sibling
      until sibling.nil? do
        return true if sibling.type.match type_pattern
        sibling = sibling.next_sibling
      end
      false
    end

    def pass scanners
      child_stack = @cur_object.nil? ? [] : @cur_object.parent.children.clone
      scanner = scanners.shift
      result = false
      # checking to see if any required children are not present
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
      # checking to see if any required children were not present
      result = false if child_stack.empty? && scanners.any? do |scanner|
        %w(* ?).any? do |operator| operator != scanner[:operator] end
      end
      result # default return value should be true?
    end # def scan
  end # class ChildRule
end