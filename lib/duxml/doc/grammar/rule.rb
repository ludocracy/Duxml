require File.expand_path(File.dirname(__FILE__) + '/pattern')

module Duxml
  Struct.new 'Scanner', :match, :operator

  module Rule
    include Pattern
    include Reportable

    attr_reader :subject, :statement, :object

    # Duxml::Rule's #qualify is only used to report errors found by its subclasses' #qualify methods
    # @param change_or_pattern [Duxml::Pattern, Duxml::Change] Change or Pattern to be reported for Rule violation
    # @return [Boolean] always false; this method should always be subclassed to apply that specific rule type's #qualify
    def qualify(change_or_pattern)
      type = (change_or_pattern.is_a?(Duxml::Change)) ? :qualify_error : :validate_error
      report type, change_or_pattern
      false
    end

    # @param change_or_pattern [Duxml::Change, Duxml::Pattern] change or pattern that rule may apply to
    # @return [Boolean] whether this rule does in fact apply
    def applies_to?(change_or_pattern)
      pattern_type = change_or_pattern.subject.name
      subject == pattern_type
    end

    # @return [String] default description for a Rule
    def description
      %(#{name} that #{relationship} of #{subject} must match #{statement.gsub('\b','')})
    end
  end # class Rule
end # module Duxml