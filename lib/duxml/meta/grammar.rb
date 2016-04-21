require File.expand_path(File.dirname(__FILE__) + '/../reportable')
require File.expand_path(File.dirname(__FILE__) + '/grammar/spreadsheet')
require File.expand_path(File.dirname(__FILE__) + '/grammar/pattern_maker')
require File.expand_path(File.dirname(__FILE__) + '/grammar/rule/children_rule')
require File.expand_path(File.dirname(__FILE__) + '/grammar/rule/attributes_rule')
require File.expand_path(File.dirname(__FILE__) + '/grammar/rule/value_rule')
require File.expand_path(File.dirname(__FILE__) + '/grammar/rule/text_rule')
#require File.expand_path(File.dirname(__FILE__) + '/grammar/relax_ng')

module Duxml
  # contains Duxml::Rules and can apply them by validating XML or qualifying user input
  # reporting Duxml::Errors to History as needed
  module Grammar
    include Enumerable
    include Reportable
    include Duxml
    include Spreadsheet
    include PatternMaker
    #include RelaxNG

    def rules
      @nodes ||= []
    end

    def update(*args)
      sleep 0
    end

    def self.xml
      Element.new('duxml:grammar').extend self
    end

    def self.import(path)
      raise Exception unless File.exists?(path)
      if %w(.xlsx .csv).include?(File.extname path)
        doc = sheet_to_xml path
        File.write(File.basename(path)+'.xml', Ox.dump(doc)) #TODO make optional!
        doc
      end
    end

    def each(&block)
      yield @nodes.each
    end

    # @return [Boolean] whether or not any rules have been defined yet in this grammar
    def defined?
      !nodes.empty?
    end

    # @return [String] lists XML schema and content rules in order of precedence
    def description
    "grammar follows: \n" +
        children.collect do |change_or_error|
          change_or_error.description
        end.join("\n")
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
      rules = get_rule(change_or_pattern)

      # define behaviors for when there are no rules applying to a given pattern
      if rules.empty?
        return true if change_or_pattern.respond_to?(:new_content)
        return true if change_or_pattern.respond_to?(:value)
        report :validate_error, change_or_pattern
        return false
      end
      results = rules.collect do |rule|
        rule.qualify change_or_pattern
      end
      !results.any? do |qualified| !qualified end
    end # def qualify

    private

    # @param change_or_pattern [Duxml::Change, Duxml::Pattern] change or pattern to be qualified
    # @return [Array[Duxml::Rule]] rules that match the pattern type (e.g. :change_content => :content_rule)
    #   and subject (e.g. change_or_pattern.subject.type => 'blobs' && rule.subject => 'blobs')
    def get_rule(change_or_pattern)
      nodes.select do |rule| rule.applies_to?(change_or_pattern) end
    end # def get_rules

    def self
      @doc.grammar
    end
  end # module Grammar
end # module Duxml