require File.expand_path(File.dirname(__FILE__) + '/../rule')

module Duxml
  class ContentRule < Rule
    # can be initialized from XML Element or Ruby args
    # args[0] must be the element to which this rule applies
    # args[1] must be the Regexp that will be matched against the given element's content
    def initialize(*args)
      if xml? args
        super *args
      else
        element_name = args.first
        statement_str = args.last
        super element_name, statement_str
      end
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