require File.expand_path(File.dirname(__FILE__) + '/../rule')

module Dux
  # rule that states what children and how many a given object is allowed to have
  class ChildrenRule < Rule
    # child rules are initialized from XML or constructed from DTD element declarations e.g. (zeroOrMore|other-first-child)*,second-child-optional?,third-child-gt1+
    # args[0] is the name of the element the rule applies to
    # args[1] is the DTD-style statement of the child rule
    def initialize(*args)
      if xml? args
        super *args
      else
        element_name = args.first
        statement_str = args.last.gsub('-','_dash_').gsub(/\b/,'\b').gsub('_dash_', '-')
        statement_str.gsub!(/[\<>]/, '')
        statement_str.gsub!(/#PCDATA/, 'p_c_data')
        super element_name, statement_str
      end
    end

    # evaluates a given change or pattern to see if their children all follow this rule
    def qualify(change_or_pattern)
      @cur_object = change_or_pattern.object meta
      super change_or_pattern unless pass
    end

    private

    def get_scanners
      statement.split(',').collect do |rule|
        rule_args = %w(? * +).include?(rule[-1]) ? [rule[0..-2], rule[-1]] : [rule, '']
        Struct::Scanner.new Regexp.new(dtd_to_regexp rule_args.first), rule_args.last
      end
    end

    # fixes annoying DTD multiple parentheses formatting
    def dtd_to_regexp(child_pattern)
      return child_pattern unless child_pattern.match(/[\(\)]/)
      s = child_pattern.clone
      open_match = s.match(/[\(]/)
      open = (s.match('\(') || []).size
      close = (s.match('\)') || []).size
      return s unless (open == 1 && close.zero?) || (open.zero? && close == 1)
      case
        when open == close then
        when s[0] == '(' && s[-1] != ')' then s = s[1..-1] until s[0] != '('
        when s[0] != '(' && s[-1] == ')' then s = s[0..-2] until s[-1] != ')'
        else
      end
      s
    end

    def pass
      child_stack = cur_object.nil? ? [] : cur_object.parent.children.clone
      scanners = get_scanners
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
        break if child.id == cur_object.id  # don't need to keep looping because we've scanned our target
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