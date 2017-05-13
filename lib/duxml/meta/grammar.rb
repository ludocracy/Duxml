# Copyright (c) 2016 Freescale Semiconductor Inc.

require File.expand_path(File.dirname(__FILE__) + '/../reportable')
require File.expand_path(File.dirname(__FILE__) + '/grammar/spreadsheet')
require File.expand_path(File.dirname(__FILE__) + '/grammar/pattern_maker')
require File.expand_path(File.dirname(__FILE__) + '/grammar/rule/children_rule')
require File.expand_path(File.dirname(__FILE__) + '/grammar/rule/attrs_rule')
require File.expand_path(File.dirname(__FILE__) + '/grammar/rule/value_rule')
require File.expand_path(File.dirname(__FILE__) + '/../doc/lazy_ox')
require File.expand_path(File.dirname(__FILE__) + '/grammar/rule/text_rule')
require 'forwardable'

module Duxml
  # module shares name with <grammar> to activate its methods when that XML Element is encountered in a Meta file
  module Grammar
    include Reportable
    include Duxml
    include Spreadsheet
    include PatternMaker
    include LazyOx
  end
  # contains Duxml::Rules and can apply them by validating XML or qualifying user input
  # reporting Duxml::Errors to History as needed
  class GrammarClass
    extend Forwardable
    include Grammar

    # @param rules [[RuleClass]] optional, can initialize grammar with rules
    def initialize(rules=[])
      @rules = rules
    end

    def_delegators :@rules, :<<, :[], :each
    attr_reader :rules
    alias_method :nodes, :rules
  end

  module Grammar
    # @param path [String] path of grammar file; can be in .xlsx, .csv or Duxml GrammarClass file
    # @return [GrammarClass, Element] XML Element named <grammar> and GrammarClass object are functionally equivalent
    def self.import(path)
      if %w(.xlsx .csv).include?(File.extname path)
        doc = Spreadsheet.sheet_to_xml path
        File.write(File.basename(path)+'.xml', Ox.dump(doc)) #TODO make optional!
        doc
      else
        Ox.parse_obj(File.read path)
      end
    end

    # @return [Doc] returns self as XML document
    def xml
      Element.new('grammar') << rules.collect do |rule| rule.xml end
    end

    # @return [History] history that this grammar is currently reporting to
    def history
      @observer_peers.first.first if @observer_peers and @observer_peers.any? and @observer_peers.first.any?
    end

    # @return [Boolean] whether or not any rules have been defined yet in this grammar
    def defined?
      !rules.empty?
    end

    # @param obj [Object] object that will observe this grammar's rules, usually the History
    def add_observer(obj, sym=nil)
      super(obj, sym || :update)
      @rules.each do |r| r.add_observer(obj, :update)end
    end

    # @return [String] lists XML schema and content rules in order of precedence
    def description
    "grammar follows: \n" +
        rules.collect do |change_or_error|
          change_or_error.description
        end.join("\n")
    end

    # @return [String] formatted to appear in tight spaces e.g. debugger
    def inspect
      "#<#{self.class.to_s} #{object_id}: @rules=#{rules.size}>"
    end

    # @return [String] 'grammar'
    def name
      'grammar'
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
      return true unless self.defined?
      rules = get_rule(change_or_pattern)

      # define behaviors for when there are no rules applying to a given pattern
      if rules.empty?

        if change_or_pattern.respond_to?(:text) or
            change_or_pattern.respond_to?(:value) or
            change_or_pattern.subject.is_a?(Doc)
          return true
        end
        report(:ValidateError, change_or_pattern)
        return false
      end
      results = rules.collect do |rule|
        rule.qualify change_or_pattern
      end
      !results.any? do |qualified| !qualified end
    end # def qualify

    # @param change_or_pattern [Duxml::Change, Duxml::Pattern] change or pattern to be qualified
    # @return [Array[Duxml::Rule]] rules that match the pattern type (e.g. :change_content => :content_rule)
    #   and subject (e.g. change_or_pattern.subject.type => 'blobs' && rule.subject => 'blobs')
    def get_rule(change_or_pattern)
      rules.select do |rule| rule.applies_to?(change_or_pattern) end
    end # def get_rules
  end # module Grammar
end # module Duxml