require File.expand_path(File.dirname(__FILE__) + '/../rule')

module Dux
  # rule that states what values a given attribute name is allowed to have
  class ValueRule < Rule
    # checks an attribute of with name #subject to see if it is allowed to have a value of type #object
    def qualify(change_or_pattern)
      @cur_object = change_or_pattern.subject meta
      super change_or_pattern unless pass
    end

    private

    def pass
      return true # TODO fix this scanner! add attribute data types!
      scanner = get_scanner
      cur_object.attributes.each do |k, v|
        return scanner[:match].match(v).to_s == v if subject == k
      end
      false
    end

    def get_scanner
      Struct::Scanner.new Regexp.new(statement), ''
    end
  end # class ContentRule
end # module Dux