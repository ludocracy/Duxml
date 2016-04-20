require File.expand_path(File.dirname(__FILE__) + '/../rule')

module Duxml
  class TextRule
    include Rule
    # @param _subject [String] the element to which this rule applies
    # @param _statement (Regexp) the Regexp that will be matched against the given element's content
    def initialize(_subject, _statement)
      @subject, @statement = _subject, _statement
    end

    attr_reader :subject, :statement

    # @param change_or_pattern [Duxml::Change, Duxml::Pattern] change or pattern that rule may apply to
    # @return [Boolean] whether this rule does in fact apply
    def applies_to?(change_or_pattern)
      super(change_or_pattern) &&
          change_or_pattern.respond_to?(:text)
    end

    # applies Regexp statement to text content of this node; returns false if content has XML
    def qualify(change_or_pattern)
      @object = change_or_pattern.subject
      result = pass
      super change_or_pattern unless result
      @object = nil
      result
    end

    private

    def pass
      return false unless object.text.is_a?(String)
      scanner = get_scanner
      scanner.match(object.text).to_s == object.text
    end

    def get_scanner
      Struct::Scanner.new Regexp.new(statement), ''
    end
  end # class ContentRule
end # module Duxml