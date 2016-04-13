require File.expand_path(File.dirname(__FILE__) + '/../rule')

module Duxml
  # rule that states what children and how many a given object is allowed to have
  class ChildrenRule < Rule
    # child rules are initialized from XML or constructed from DTD element declarations e.g. (zeroOrMore|other-first-child)*,second-child-optional?,third-child-gt1+
    #
    # @param *args [String] name of the element the rule applies to and DTD-style statement of the rule
    def initialize(*args)
      if xml? args
        super *args
      else
        element_name = args.first
        statement_str = args.last.gsub('-','_dash_').gsub(/\b/,'\b').gsub('_dash_', '-')
        statement_str.gsub!(/[\<>]/, '')
        statement_str.gsub!(/#PCDATA/, 'p_c_data')
        super element_name, statement_str
      end
    end

    # @param change_or_pattern [Duxml::Pattern, Duxml::Change] to be evaluated to see if it follows this rule
    # @return [Boolean] whether or not change_or_pattern#subject is allowed to have #object as its child
    #   if false, Error is reported to History
    def qualify(change_or_pattern)
      @cur_object = change_or_pattern.object meta
      result = pass
      super change_or_pattern unless result
      result
    end

    # TODO either make RelaxNG module or get parent.xpath to find needed element_def
    # @param parent [Nokogiri::XML::Node] parent from RelaxNG document under construction (should be <grammar/>)
    # @return [Nokogiri::XML::Node] same parent but with addition of <define><element> with #statement converted into <ref>'s
    #   these are wrapped as needed in <zeroOrMore>,<oneOrMore>, or <optional>
    def relaxng(parent)
      s = subject
      element_def = parent.document.xpath("//element[@name='#{subject}']")[0]
      if element_def.nil?
        element_def ||= element 'element', name: subject
        define = element('define', name: subject) << element_def
        parent << define
      else
        sleep 0
      end

      get_scanners.each do |scanner|
        operator_name = case scanner[:operator]
                          when '?' then :optional
                          when '*' then :zeroOrMore
                          when '+' then :oneOrMore
                          else nil
                        end
        if operator_name
          cur_element = element(operator_name.to_s)
          element_def << cur_element
        else
          cur_element = element_def
        end

        element_array = scanner[:match].source.gsub('\b','').scan(Regexp.nmtoken).flatten
        if element_array.size > 1
          cur_element = element 'choice'
          element_def << cur_element
        end
        element_array.each do |element_name|
          unless parent.xpath("//element[@name='#{element_name}']")
            new_def = element [[:define, {name: element_name}],[:element, {name: element_name}]]
            parent << new_def
          end

          if element_name == 'PCDATA'
            cur_element << element('text')
          else
            cur_element << element('ref', name: element_name)
          end
        end # element_array.each
      end # get_scanners.each
      parent
    end # def relaxng

    private

    def get_scanners
      statement.split(',').collect do |rule|
        r = rule.gsub(/[\(\)]/, '')
        r = r[0..-2] if r[-1].match(/[\?\+\*]/)
        operator = %w(? * +).include?(rule[-1]) ? rule[-1] : ''
        Struct::Scanner.new Regexp.new(r), operator
      end
    end

    def pass
      child_stack = cur_object.nil? ? [] : cur_object.parent.children.clone
      scanners = get_scanners
      scanner = scanners.shift
      result = false
      loop do
        child = child_stack.shift
        break if child.nil? || scanner.nil?
        if child.type.match scanner[:match] # scanner matches this child
          if ['?', ''].any? do |op| op == scanner[:operator] end # shift scanners if we only need one child of this type
            scanner = scanners.shift
            result = child.previous_sibling.nil? || (child.previous_sibling.type != child.type)
          else
            result = true
          end
        else # scanner does not match this child
          case scanner[:operator]
            when '?', '*' # optional scanner so try next scanner on same child
              scanner = scanners.shift
              child_stack.unshift child
              result = true # store as last result
            else
              result = false # else, this scanner will report false
          end
        end # if child.type.match scanner[:match]
        break if child.id == cur_object.id  # don't need to keep looping because we've scanned our target
      end # loop do
      # checking to see if any required children were not present
      result = false if child_stack.empty? && scanners.any? do |scanner|
        %w(* ?).any? do |operator|
          operator != scanner[:operator]
        end
      end
      result
    end # def pass
  end # class ChildrenRule
end # module Duxml