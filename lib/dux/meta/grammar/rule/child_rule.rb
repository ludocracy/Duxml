require File.expand_path(File.dirname(__FILE__) + '/../rule')

module Dux
  # rule that states what children and how many a given object is allowed to have
  class ChildRule < Rule
    Struct.new 'Scanner', :match, :operator, :counter

    def qualify(change_or_pattern)
      @cur_object = change_or_pattern.object meta
      rule_array = statement.split(',').collect do |rule|
        %w(? * +).include?(rule[-1]) ? [rule[0..-2], rule[-1]] : [rule, '']
      end
      scanners = get_scanners rule_array
      super change_or_pattern unless pass scanners
    end

    def description
      %(#{name} which states that children of <#{subject}> must match #{statement})
    end

    private

    def get_scanners(rule_array)
      rule_array.collect do |rule|
        Struct::Scanner.new Regexp.new(dtd_to_regexp rule.first), rule.last, 0
      end
    end

    def dtd_to_regexp(child_pattern)
      # add code to add \b when '<>' not present!
      s = child_pattern.gsub('#PCDATA', 'p_c_data').gsub('-','_dash_').gsub(/\b/,'\b').gsub('_dash_', '-')
      open = s.match('\(') || []
      close = s.match('\)') || []
      case
        when open.size == close.size then
        when s[0] == '(' && s[-1] != ')' then s = s[1..-1] until s[0] != '('
        when s[0] != '(' && s[-1] == ')' then s = s[0..-2] until s[-1] != ')'
        else
      end
      s
    end

    def any_next_type_siblings?(type_pattern, child)
      sibling = child.next_sibling
      until sibling.nil? do
        return true if sibling.type.match type_pattern
        sibling = sibling.next_sibling
      end
      false
    end

    def pass(scanners)
      child_stack = @cur_object.nil? ? [] : @cur_object.parent.children.clone
      scanner = scanners.shift
      result = false
      loop do
        child = child_stack.shift
        break if child.nil? || scanner.nil?
        if child.type.match scanner[:match] # scanner matches this child
          if ['?', ''].any? do |op| op == scanner[:operator] end # shift scanners if we only need one child of this type
            scanner = scanners.shift
            result = child.previous_sibling.nil? || (child.previous_sibling.type != child.type)
          else
            result = true
          end
        else # scanner does not match this child
          case scanner[:operator]
            when '?', '*' # optional scanner so try next scanner on same child
              scanner = scanners.shift
              child_stack.unshift child
              result = true # store as last result
            else
              result = false # else, this scanner will report false
          end
        end # if child.type.match scanner[:match]
        break if child.id == @cur_object.id  # don't need to keep looping because we've scanned our target
      end # loop do
      # checking to see if any required children were not present
      result = false if child_stack.empty? && scanners.any? do |scanner|
        %w(* ?).any? do |operator|
          operator != scanner[:operator]
        end
      end
      result
    end # def scan
  end # class ChildRule
end # module Dux