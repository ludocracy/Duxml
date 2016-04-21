require File.expand_path(File.dirname(__FILE__) + '/../rule')

module Duxml
  # rule that states what attribute names a given object is allowed to have
  class AttributesRule
    include Rule

    # @param _subject [String] name of the doc
    # @param attrs [String] the attribute name pattern in Regexp form
    # @param required [String] the requirement level - optional i.e. #IMPLIED by default
    def initialize(_subject, attrs, required='#IMPLIED')
      @subject = _subject
      @statement = attrs.gsub('-', '__dash__').gsub(/\b/, '\b').gsub('-', '__dash__')
      @requirement = required
    end

    attr_reader :subject, :statement, :requirement

    # @param change_or_pattern [Duxml::Pattern] checks an doc of type change_or_pattern.subject against change_or_pattern
    # @return [Boolean] whether or not given pattern passed this test
    def qualify(change_or_pattern)
      @object = change_or_pattern
      result = pass change_or_pattern
      super change_or_pattern unless result
      @object = nil
      result
    end

    # @param change_or_pattern [Duxml::Change, Duxml::Pattern] change or pattern that rule may apply to
    # @return [Boolean] whether this rule does in fact apply
    def applies_to?(change_or_pattern)
      return false unless change_or_pattern.respond_to?(:attr_name)
      return false unless super(change_or_pattern)
      statement.include?(change_or_pattern.attr_name.to_s)
    end

    # @return [Boolean] whether or not this attribute is required
    def required?
      requirement == '#REQUIRED'
    end

    # @return [String] name of attribute to which this rule applies
    def attr_name
      statement.gsub('\b','')
    end

    # @return [String] description of self; overrides super to account for cases of missing, required attributes
    def description
      %(#{name} that #{relationship} of #{subject} #{required? ? 'must':'can'} include #{attr_name})
    end

    # @param change_or_pattern [Duxml::Change, Duxml::Pattern] change or pattern to be evaluated
    # @return [Boolean] true if this rule does not apply to param; false if pattern is for a missing required attribute
    #   otherwise returns whether or not any illegal attributes exist
    def pass(change_or_pattern)
      if change_or_pattern.is_a?(Duxml::Change)
        attr_name.include?(change_or_pattern.attr_name.to_s)
      else
        !change_or_pattern.abstract?
      end
    end # def pass
  end # class AttributesRule
end # module Duxml