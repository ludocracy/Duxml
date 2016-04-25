require File.expand_path(File.dirname(__FILE__) + '/pattern')
require File.expand_path(File.dirname(__FILE__) + '/../../reportable')

module Duxml
  Struct.new 'Scanner', :match, :operator
  module Rule
    include Reportable
  end

  class RuleClass < PatternClass
    include Rule

    # @param subj [String] NMTOKEN name of element this rule applies to
    # @param _statement [String, Regexp] string statement of rule in DTD declaration form or Regexp
    def initialize(subj, _statement)
      @statement = _statement
      @object = nil
      super subj
    end

    attr_reader :statement, :object
  end

  module Rule
    # Duxml::Rule's #qualify is only used to report errors found by its subclasses' #qualify methods
    # @param change_or_pattern [Duxml::Pattern, Duxml::Change] Change or Pattern to be reported for Rule violation
    # @return [Boolean] always false; this method should always be subclassed to apply that specific rule type's #qualify
    def qualify(change_or_pattern)
      type = (change_or_pattern.respond_to?(:time_stamp)) ? :QualifyError : :ValidateError
      report(type, change_or_pattern)
      false
    end

    # @return [HistoryClass] history to which this rule will report errors
    def history
      @observer_peers.first.first if @observer_peers.any? and @observer_peers.first.any?
    end

    # @param change_or_pattern [Duxml::Change, Duxml::Pattern] change or pattern that rule may apply to
    # @return [Boolean] whether this rule does in fact apply
    def applies_to?(change_or_pattern)
      pattern_type = change_or_pattern.subject.name
      subject == pattern_type
    end

    # @return [String] default description for a Rule
    def description
      statement_str = (statement.is_a?(String) ? statement : statement.inspect).gsub('\b','')
      %(#{relationship.capitalize} Rule that <#{subject}>'s #{relationship} must match '#{statement_str}')
    end
  end # module Rule
end # module Duxml