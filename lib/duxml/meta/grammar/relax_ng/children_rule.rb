require File.expand_path(File.dirname(__FILE__) + '/../rule/children_rule')

module Duxml
  module RngChildrenRule; end

  class ChildrenRuleClass
    include RngChildrenRule
  end

  module RngChildrenRule
    include Duxml::LazyOx
    include Ox

    # @param parent [Ox::Element] parent from RelaxNG document under construction (should be <grammar/>)
    # @return [Ox::Element] same parent but with addition of <define><doc> with #statement converted into <ref>'s
    #   these are wrapped as needed in <zeroOrMore>,<oneOrMore>, or <optional>
    def relaxng(parent)
      nodes = parent.Define(name: subject)
      raise Exception if nodes.size > 1

      if nodes.first.nil?
        element_def = Element.new('element')
        element_def[:name] = subject
        define = Element.new('define')
        define[:name] = subject
        define << element_def
        parent << define
      else
        element_def = nodes.first.nodes.first
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
          cur_element = Element.new(operator_name.to_s)
          element_def << cur_element
        else
          cur_element = element_def
        end

        # if child requirement has enumerated options, wrap in <choice>
        element_array = scanner[:match].source.gsub('\b','').scan(Regexp.nmtoken).flatten.keep_if do |e| !e.empty? end
        if element_array.size > 1
          choice_el = Element.new 'choice'
          cur_element << choice_el
          cur_element = choice_el
        end

        # adding enumerated options as new element defs if needed
        element_array.each do |element_name|
          existing_defs = parent.Define(name: element_name)
          raise Exception if existing_defs.size > 1
          if existing_defs.empty?
            new_def = Element.new('define')
            new_def[:name] = element_name
            child_el_def = Element.new('element')
            child_el_def[:name] = element_name
            new_def << child_el_def
            parent << new_def
          end

          if element_name == '#PCDATA'
            cur_element << Element.new('text')
          else
            ref_node = Element.new('ref')
            ref_node[:name] = element_name
            cur_element << ref_node
          end
        end # element_array.each
      end # get_scanners.each
      parent
    end # def relaxng
  end # module RngChildrenRule
end # module Duxml