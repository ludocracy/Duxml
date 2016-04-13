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

    # @param change_or_pattern [Dux::Pattern] checks an element of type change_or_pattern.subject against change_or_pattern
    # @return [Boolean] whether or not given pattern passed this test
    def qualify(change_or_pattern)
      @cur_object = change_or_pattern.subject meta
      result = pass
      super change_or_pattern unless result
      result
    end

    # @param parent [Nokogiri::XML::Node] should be <grammar>
    # @return [Nokogiri::XML::Node] parent, but with additions of <define><attribute> to parent if does not already exist and <ref> to respective <define><element>
    def relaxng(parent)
      # TODO this is here just to skip generation from namespaced attributes - fix later!!!
      return parent if attr_name.include?(':')
      # TODO

      # if new attribute declaration needed
      unless parent.element_children.any? do |attr_def| attr_def[:name] == attr_name end
        parent << element('define', {name: attr_name}, element('attribute', name: attr_name))
      end

      # update element with ref, updating previous <optional> if available
      parent.element_children.reverse.each do |define|
        if define[:name] == subject
          element_def = define.element_children.first
          if get_scanner[:operator]=='#IMPLIED'
            if element_def.element_children.last.name == 'optional'
              cur_element = element_def.element_children.last
            else
              cur_element = element 'optional'
              element_def << cur_element
            end
          else
            cur_element = element_def
          end
          cur_element << element('ref', name: attr_name)
          break
        end
      end
      parent
    end # def relaxng

    # @return [String] name of attribute to which this rule applies
    def attr_name
      statement.gsub('\b','')
    end

    private

    # @return [String] describes relationship of rule objects to subjects
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
  end # class AttributesRule
end # module Duxml