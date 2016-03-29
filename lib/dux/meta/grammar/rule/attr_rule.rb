require File.expand_path(File.dirname(__FILE__) + '/../rule')

module Dux
  class AttrRule < Rule
    def qualify object
      @cur_object = object
      rule_array = content.split(',').collect do |rule|
        %w(? * +).include?(rule[-1]) ? [rule[0..-2], rule[-1]] : [rule, '']
      end
      scanners = get_scanners rule_array
      child_stack = object.nil? ? [] : object.parent.children.clone
      scan scanners, child_stack
    end

    private

    def get_scanners rule_array
      Struct.new 'Scanner', :match, :operator, :counter
      rule_array.collect do |rule|
        Struct::Scanner.new Regexp.new(dtd_to_regexp rule.first), rule.last, 0
      end
    end

    def dtd_to_regexp child_pattern
      child_pattern.gsub(/<>/, '')
    end

    def scan scanners, child_stack
    end # def scan
  end # class AttrRule
end # module Dux