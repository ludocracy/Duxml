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
        @xml[:requirement] = args[2] || '#IMPLICIT'
      end
    end

    # checks an element of type #subject to see if it is allowed to have a given attribute with name #object
    def qualify(change_or_pattern)
      @cur_object = change_or_pattern.subject meta
      result = pass
      super change_or_pattern unless result
      result
    end

    private

    # string describing relationship of rule objects to subjects
    def relationship
      'attributes'
    end

    def pass
      scanner = get_scanner
      result = false
      cur_object.attributes.each do |k, v|
        if scanner[:match].match(k.to_s).to_s == k.to_s
          if result
            result = false
            break
          else
            result = true
          end
        end
      end
      case scanner[:operator]
        when '#IMPLIED' then true
        when '#REQUIRED' then result
        when '#FIXED' then true # TODO assess how to handle this case better
        else true
      end
    end

    def get_scanner
      Struct::Scanner.new Regexp.new(statement), self[:requirement]
    end
  end # class AttrRule
end # module Duxml