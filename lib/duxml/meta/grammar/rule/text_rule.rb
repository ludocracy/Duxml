# Copyright (c) 2016 Freescale Semiconductor Inc.

require File.expand_path(File.dirname(__FILE__) + '/../rule')

module Duxml
  module TextRule; end

  class TextRuleClass < RuleClass
    include TextRule
  end

  module TextRule
    # @param change_or_pattern [Duxml::Change, Duxml::Pattern] change or pattern that rule may apply to
    # @return [Boolean] whether this rule does in fact apply
    def applies_to?(change_or_pattern)
      super(change_or_pattern) &&
          change_or_pattern.respond_to?(:text)
    end

    # applies Regexp statement to text content of this node; returns false if content has XML
    def qualify(change_or_pattern)
      @object = change_or_pattern
      result = pass
      super change_or_pattern unless result
      @object = nil
      result
    end

    private

    def pass
      return false unless object.text.is_a?(String)
      get_scanner.match(object.text).to_s == object.text
    end

    def get_scanner
      Regexp.new(statement)
    end
  end # module TextRule
end # module Duxml