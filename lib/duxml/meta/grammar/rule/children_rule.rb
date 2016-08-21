# Copyright (c) 2016 Freescale Semiconductor Inc.

require File.expand_path(File.dirname(__FILE__) + '/../rule')
require File.expand_path(File.dirname(__FILE__) + '/../../../doc/element')

module Duxml
  # methods to apply rule on what children an Element may have
  module ChildrenRule; end

  # do not subclass! rule that states what children and how many a given element is allowed to have where @statement
  # is a DTD/Regexp of what children are allowed, how many, in what order and whether they are required
  class ChildrenRuleClass < RuleClass
    include ChildrenRule
    # child rules are initialized from DTD doc declarations e.g. (zeroOrMore|other-first-child)*,second-child-optional?,third-child-gt1+
    #
    # @param _subject [String] name of the doc the rule applies
    # @param _statement [String] DTD-style statement of the rule
    def initialize(_subject, _statement)
      formatted_statement = _statement
                                .gsub(/[\<>]/, '')
                                .gsub(/#PCDATA/, 'PCDATA')
                                .gsub('-','_dash_')
                                .gsub(/\b/,'\b')
                                .gsub(/PCDATA/, '#PCDATA')
                                .gsub('_dash_', '-')
                                .gsub(/\s/,'')
      super(_subject, formatted_statement)
    end
  end # class ChildrenRuleClass

  module ChildrenRule
    # @param change_or_pattern [Duxml::ChildPattern, Duxml::Add, Duxml::Remove] to be evaluated to see if it follows this rule
    # @return [Boolean] whether or not change_or_pattern#subject is allowed to have #object as its child
    #   if false, Error is reported to History
    def qualify(change_or_pattern)
      @object = change_or_pattern
      result = pass
      super change_or_pattern unless result
      @object = nil
      result
    end

    # @return [Array[String]] in order, array of child doc types required by this rule
    def required_children
      req_scans = get_scanners.select do |scanner| scanner[:operator].match(/[\*\?]/).nil? end
      req_scans.collect do |req_scan|
        get_child_name req_scan unless get_child_name(req_scan) == 'EMPTY'
      end.compact
    end

    # @param change_or_pattern [Duxml::Pattern, Duxml::Change] change or pattern to be evaluated
    # @return [Boolean] whether subjects agree, and change or pattern is not a Rule and responds to #affected_parent
    def applies_to?(change_or_pattern)
      case
        when change_or_pattern.is_a?(Duxml::Rule) then false
        when super(change_or_pattern) && change_or_pattern.respond_to?(:parent)
          true
        else
          false
      end
    end

    private

    # @param req_scan [Struct::Scanner] scanner with which to identify a child name within @statement
    # @return [String] name of child that is currently being checked for by this rule
    def get_child_name(req_scan)
      req_scan[:match].inspect.split(/[\/(\\b)]/).select do |word| !word.empty? end.first
    end

    # @return [[Struct::Scanner]] array of scanners for each logical component of @statement to be applied to target Element's children
    def get_scanners
      statement.split(',').collect do |rule|
        r = rule.gsub(/[\(\)]/, '')
        operator = r[-1].match(/[\?\+\*]/) ? r[-1] : ''
        r = r[0..-2] unless operator.empty?
        Struct::Scanner.new Regexp.new(r), operator
      end
    end

    attr_reader :child_stack

    # @return [Boolean] whether or not this rule has been passed
    def pass
      @child_stack = object.child.nil? ? [] : object.parent.nodes.clone
      scanners = get_scanners
      scanner = scanners.shift
      result = false
      loop do
        child = @child_stack.shift
        case
          when child.nil?, scanner.nil? then break
          when child.is_a?(String)
            result = scanner[:match].inspect.include?('#PCDATA')
          when child.name.match(scanner[:match]) # scanner matches this child
            if scanner[:operator]=='?' or scanner[:operator]=='' # shift scanners if we only need one child of this type
              scanner = scanners.shift
              result = previous_child.nil? || (previous_child.name != child.name)
            else
              result = true
            end
          # scanner does not match this child...
          when %w(? *).include?(scanner[:operator]) # optional scanner so try next scanner on same child
            scanner = scanners.shift
            @child_stack.unshift child
            result = !scanner.nil?
          else
            result = false # else, this scanner will report false
        end # case
        return result unless child.is_a?(String) or !matching_index?# don't need to keep looping because we've scanned our target
      end # loop do

      # checking to see if any required children were not present
      result = false if child_stack.empty? && scanners.any? do |scanner|
        scanner[:operator] != '*' or scanner[:operator] != '?'
      end
      result
    end # def pass

    # @return [Boolean] whether the child currently being scanned is the one in the pattern we are testing now
    def matching_index?
      child_index == object.index
    end

    # @return [Fixnum] index of child currently being scanned
    def child_index
      object.parent.nodes.size-child_stack.size-1
    end

    # @return [Element] previous element to the one being scanned
    def previous_child
      index = child_index - 1
      index < 0 ? nil : object.parent.nodes[index]
    end
  end # module ChildrenRule
end # module Duxml