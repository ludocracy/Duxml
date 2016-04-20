require File.expand_path(File.dirname(__FILE__) + '/../rule')

module Duxml
  # rule that states what children and how many a given object is allowed to have
  class ChildrenRule
    include Rule
    # child rules are initialized from DTD element declarations e.g. (zeroOrMore|other-first-child)*,second-child-optional?,third-child-gt1+
    #
    # @param _element [String] name of the element the rule applies
    # @param _statement [String] DTD-style statement of the rule
    def initialize(_element, _statement)
      @element = _element
      @statement = _statement
                       .gsub(/[\<>]/, '')
                       .gsub(/#PCDATA/, 'p_c_data')
                       .gsub('-','_dash_')
                       .gsub(/\b/,'\b')
                       .gsub('_dash_', '-')
    end

    attr_reader :element, :statement

    # @param change_or_pattern [Duxml::ChildPattern, Duxml::Add, Duxml::Remove] to be evaluated to see if it follows this rule
    # @return [Boolean] whether or not change_or_pattern#subject is allowed to have #object as its child
    #   if false, Error is reported to History
    def qualify(change_or_pattern)
      @cur_object = change_or_pattern.object meta
      result = pass
      super change_or_pattern unless result
      result
    end

    # @return [Array[String]] in order, array of child element types required by this rule
    def required_children
      req_scans = get_scanners.select do |scanner| scanner[:operator].match(/[\*\?]/).nil? end
      req_scans.collect do |req_scan|
        req_scan[:match].inspect.split(/[\/(\\b)]/).select do |word| !word.empty? end.first
      end
    end

    # @param change_or_pattern [Duxml::Pattern, Duxml::Change] change or pattern to be evaluated
    # @return [Boolean] whether subjects agree, and change or pattern is not a Rule and responds to #affected_parent
    def applies_to?(change_or_pattern)
      super(change_or_pattern) &&
          !change_or_pattern.respond_to?(:violated_rule) &&
          change_or_pattern.respond_to?(:affected_parent)
    end

    private

    def get_scanners
      statement.split(',').collect do |rule|
        r = rule.gsub(/[\(\)]/, '')
        operator = r[-1].match(/[\?\+\*]/) ? r[-1] : ''
        r = r[0..-2] unless operator.empty?
        Struct::Scanner.new Regexp.new(r), operator
      end
    end

    def pass
      child_stack = cur_object.nil? ? [] : cur_object.parent.children.clone
      scanners = get_scanners
      scanner = scanners.shift
      result = false
      loop do
        child = child_stack.shift
        break if child.nil? || scanner.nil?
        if child.name.match scanner[:match] # scanner matches this child
          if ['?', ''].any? do |op| op == scanner[:operator] end # shift scanners if we only need one child of this type
            scanner = scanners.shift
            result = child.previous_sibling.nil? || (child.previous_sibling.name != child.name)
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
        end # if child.name.match scanner[:match]
        return result if child.id == cur_object.id  # don't need to keep looping because we've scanned our target
      end # loop do
      # checking to see if any required children were not present
      result = false if child_stack.empty? && scanners.any? do |scanner|
        %w(* ?).any? do |operator|
          operator != scanner[:operator]
        end
      end
      result
    end # def pass
  end # class ChildrenRule
end # module Duxml