require File.expand_path(File.dirname(__FILE__) + '/../rule')

module Duxml
  class TextRule
    include Rule
    # @param _element [String] the element to which this rule applies
    # @param _statement (Regexp) the Regexp that will be matched against the given element's content
    def initialize(_element, _statement)
      @element, @statement = _element, _statement
    end

    attr_reader :element, :statement

    # @param change_or_pattern [Duxml::Change, Duxml::Pattern] change or pattern that rule may apply to
    # @return [Boolean] whether this rule does in fact apply
    def applies_to?(change_or_pattern)
      super(change_or_pattern) &&
          change_or_pattern.respond_to?(:new_content)
    end

    # applies Regexp statement to text content of this node; returns false if content has XML
    def qualify(change_or_pattern)
      @cur_object = change_or_pattern.subject meta
      super change_or_pattern unless pass
    end

    private

    def pass
      return false unless cur_object.text?
      scanner = get_scanner
      scanner.match(cur_object.content).to_s == cur_object.content
    end

    def get_scanner
      Struct::Scanner.new Regexp.new(statement), ''
    end
  end # class ContentRule
end # module Duxml