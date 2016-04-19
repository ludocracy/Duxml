require File.expand_path(File.dirname(__FILE__) + '/../rule/children_rule.rb')

module Duxml
  ChildrenRule.class_eval do
    # TODO either make RelaxNG module or get parent.xpath to find needed element_def
    # @param parent [Nokogiri::XML::Node] parent from RelaxNG document under construction (should be <grammar/>)
    # @return [Nokogiri::XML::Node] same parent but with addition of <define><element> with #statement converted into <ref>'s
    #   these are wrapped as needed in <zeroOrMore>,<oneOrMore>, or <optional>
    def relaxng(parent)
      nodes = parent.css("element[@name='#{subject}']")
      raise Exception if nodes.size > 1
      element_def = nodes.first

      if element_def.nil?
        element_def ||= element 'element', name: subject
        define = element('define', name: subject) << element_def
        parent << define
      end

      # loop through child requirements
      get_scanners.each do |scanner|
        # wrap in requirement node if needed
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

        # if child requirement has enumerated options, wrap in <choice>
        element_array = scanner[:match].source.gsub('\b','').scan(Regexp.nmtoken).flatten
        if element_array.size > 1
          choice_el = element 'choice'
          cur_element << choice_el
          cur_element = choice_el
        end

        # adding enumerated options as new element defs if needed
        element_array.each do |element_name|
          nodes = parent.css("element[@name='#{element_name}']")
          raise Exception if nodes.size > 1
          if nodes.empty?
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
  end # ChildrenRule.class_eval
end # module Duxml