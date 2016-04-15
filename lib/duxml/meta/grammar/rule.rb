require File.expand_path(File.dirname(__FILE__) + '/pattern')

module Duxml
  Struct.new 'Scanner', :match, :operator
  # do not use - must be subclassed!
  class Rule < Pattern
    @cur_object
    attr_reader :cur_object
    # can be initialized from XML Element or Ruby arguments
    # args[0] must be the subject (e.g. name of element or attribute)
    # args[1] must be the statement of the rule in Regexp/DTD form
    #
    # Rule@cur_object can only be set by the Grammar as it validates a given Change or Pattern
    # it indicates the Object currently being inspected by this Rule
    # @param *args [several_variants]
    def initialize(*args)
      super *args
      unless xml? args
        @xml << xml[:object].gsub(/\s/, '')
        @xml.remove_attribute 'object'
      end
      @cur_object = nil
    end

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
      pattern_type = change_or_pattern.subject(meta).simple_class
      subject == pattern_type
    end

    # @return [String] default description for a Rule
    def description
      %(#{name} that #{relationship} of #{subject} must match #{statement.gsub('\b','')})
    end

    # @return [String] DTD or Ruby code statement that embodies this Rule
    def statement
      xml.content
    end

    # subject of Rule is not an object but a type or
    # @return [Stringaa] name of XML element or attribute to which this rule applies
    def subject(context_root=nil)
      self[:subject]
    end

    # @return [NilClass, Duxml::Object] object of Rule is nil but during #qualify
    #   can be the object matching type given by #subject that is currently being qualified
    def object(context_root=nil)
      self[:object]
    end
  end # class Rule
end # module Duxml