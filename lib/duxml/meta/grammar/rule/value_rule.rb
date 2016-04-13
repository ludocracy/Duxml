require File.expand_path(File.dirname(__FILE__) + '/../rule')

module Duxml
  # rule that states what values a given attribute name is allowed to have
  class ValueRule < Rule
    CDATA_EXPR = /(\]\]>)/
    ENTITY_EXPR = /(\b[\S]+\b)/
    ID_EXPR = /(\b[\w-]+\b)/
    NMTOKEN_EXPR = ID_EXPR
    NOTATION_EXPR = //

    # can be initialized from XML Element or Ruby args
    # args[0] must be the name of the element this rule applies to
    # args[1] must be the attribute name
    # args[2] must be an expression of the rule for the given attribute's value
    #
    # @param *args [*several_variants]
    def initialize(*args)
      if xml? args
        super *args
      else
        raise Exception unless args.size == 3
        h = {subject: args.first, attr_name: args[1], object: args[2]}
        super h
      end
    end

    # @return [String] description of this rule
    def description
      %(#{name} that #{relationship} of <#{subject}>'s @#{attr_name} must match #{statement})
    end

    # @param change_or_pattern [Duxml::Pattern, Duxml::Change] change or pattern to be evaluated
    # @return [Boolean] whether change_or_pattern#subject is allowed to have value of type #object
    #   if false, reports Error to History
    def qualify(change_or_pattern)
      return true unless change_or_pattern.attr_name == self[:attr_name]
      @cur_object = change_or_pattern.subject meta
      result = pass change_or_pattern.value(meta)
      super change_or_pattern unless result
      result
    end

    # @param [Nokogiri::XML::Node] parent node in RelaxNG document, NOT this Rule's document
    # @return [Nokogiri::XML::Node] rule transformed into RelaxNG define element
    # TODO this assumes that attributes are always GLOBAL!!!
    def relaxng(parent)
      parent.element_children.each do |attr_def|
        if attr_def[:name] == attr_name
          attr_def << element('data', type: statement)
          return parent
        end
      end
    end

    # @return [String] name of the attribute to which this Rule applies
    def attr_name
      self[:attr_name]
    end


    private

    def pass(value)
      scanner = get_scanner
      matcher = scanner[:match]
      if matcher.respond_to?(:match)
        matcher.match(value).to_s == value
      else
        matcher.call(value)
      end
    end

    def get_scanner
      Struct::Scanner.new find_method_or_expr, ''
    end

    def find_method_or_expr
      s = statement
      case s
        when 'CDATA'                      # unparsed character data e.g. '<not-xml>'; may not contain string ']]>'
          proc do |val| val.match(CDATA_EXPR).nil? end
        when 'ID'                         # unique id among siblings, i.e. TreeNode#name
          proc do |val| val.match(ID_EXPR) && val == subject.id end
        when 'IDREF'                      # id of another element
          proc do |val| val.match(ID_EXPR) && resolve_ref(val, subject.meta) end
        when 'IDREFS'                     # ids of other elements
          proc do |val|
            separate_list val do |sub_val|
              sub_val.match(ID_EXPR) && resolve_ref(sub_val, subject.meta)
            end
          end
        when 'NMTOKEN'  then NMTOKEN_EXPR # valid XML name
        when 'NMTOKENS'                   # a list of valid XML names
          proc do |val|
            separate_list val do |sub_val|
              sub_val.match NMTOKEN_EXPR
            end
          end
        when 'ENTITY'   then ENTITY_EXPR	# an entity
        when 'ENTITIES'                   # list of entities
          proc do |val|
            separate_list val do |sub_val|
              sub_val.match ENTITY_EXPR
            end
          end
        when 'NOTATION' then //	# TODO name of a notation
        when 'xml:'     then // # TODO predefined XML value
        else                    # '|'-separated list of allowable values i.e. Regexp-style DTD declaration
          Regexp.new(s)
      end
    end # def find_method_or_expr

    def separate_list(spc_sep_vals, &block)
      spc_sep_vals.split(' ').any? do |sub_val|
        result = block.call sub_val
        !result
      end
    end
  end # class ValueRule
end # module Duxml