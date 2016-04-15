require File.expand_path(File.dirname(__FILE__) + '/../rule')

module Duxml
  # rule that states what attribute names a given object is allowed to have
  class AttributesRule < Rule
    # can be initialized from XML Element or Ruby args
    # args[0] must be the name of the element
    # args[1] must be the attribute name pattern in Regexp form
    # args[2] can be the requirement level - optional i.e. #IMPLICIT by default
    def initialize(*args)
      if xml? args
        super *args
      else
        super args.first, args[1].gsub('-', '__dash__').gsub(/\b/, '\b').gsub('-', '__dash__')
        @xml[:requirement] = args[2] || '#IMPLIED'
      end
    end

    # @param change_or_pattern [Duxml::Pattern] checks an element of type change_or_pattern.subject against change_or_pattern
    # @return [Boolean] whether or not given pattern passed this test
    def qualify(change_or_pattern)
      result = pass change_or_pattern
      super change_or_pattern unless result
      result
    end

    # @param change_or_pattern [Duxml::Change, Duxml::Pattern] change or pattern that rule may apply to
    # @return [Boolean] whether this rule does in fact apply
    def applies_to?(change_or_pattern)
      return false unless change_or_pattern.respond_to?(:attr_name)
      return false unless super(change_or_pattern)
      change_or_pattern.attr_name == attr_name
    end

    # @return [Boolean] whether or not this attribute is required
    def required?
      self[:requirement] == '#REQUIRED'
    end

    # @return [String] name of attribute to which this rule applies
    def attr_name
      statement.gsub('\b','')
    end

    # @return [String] description of self; overrides super to account for cases of missing, required attributes
    def description
      %(#{name} that #{relationship} of #{subject} #{required? ? 'must':'can'} include #{attr_name})
    end

    private

    # @return [String] describes relationship of rule objects to subjects
    def relationship
      'attributes'
    end

    # @param change_or_pattern [Duxml::Change, Duxml::Pattern] change or pattern to be evaluated
    # @return [Boolean] true if this rule does not apply to param; false if pattern is for a missing required attribute
    #   otherwise returns whether or not any illegal attributes exist
    def pass(change_or_pattern)
      !change_or_pattern.abstract?(meta)
    end # def pass
  end # class AttributesRule
end # module Duxml