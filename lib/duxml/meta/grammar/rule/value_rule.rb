require File.expand_path(File.dirname(__FILE__) + '/../rule')

module Duxml
  module ValueRule; end

  # rule that states what values a given attribute name is allowed to have
  class ValueRuleClass < RuleClass
    include ValueRule

    # @param _attr_name [String] the attribute name
    # @param _statement [String] data type or expression of the rule for the given attribute's value
    def initialize(_attr_name, _statement)
      @attr_name, @statement = _attr_name, _statement
    end

    attr_reader :attr_name
  end

  module ValueRule
    CDATA_EXPR = /(\]\]>)/
    ENTITY_EXPR = /(\b[\S]+\b)/
    ID_EXPR = /(\b[\w-]+\b)/
    NMTOKEN_EXPR = ID_EXPR
    NOTATION_EXPR = //

    # @return [true]
    def abstract?
      true
    end

    # @return [String] description of this rule
    def description
      %(#{name} that #{relationship} of @#{attr_name} must match #{statement})
    end

    # @param change_or_pattern [Duxml::Pattern, Duxml::Change] change or pattern to be evaluated
    # @return [Boolean] whether change_or_pattern#subject is allowed to have value of type #object
    #   if false, reports Error to History
    def qualify(change_or_pattern)
      value = change_or_pattern.value
      s = change_or_pattern.subject
      raise Exception if value.nil?
      result = pass value
      super change_or_pattern unless result
      result
    end

    # @param change_or_pattern [Duxml::Change, Duxml::Pattern] change or pattern that rule may apply to
    # @return [Boolean] whether this rule does in fact apply
    def applies_to?(change_or_pattern)
          return false unless change_or_pattern.respond_to?(:attr_name)
          return false unless change_or_pattern.respond_to?(:value)
          change_or_pattern.attr_name == attr_name
    end

    private

    def pass(value)
      matcher = find_method_or_expr
      if matcher.respond_to?(:match)
        matcher.match(value).to_s == value
      else
        matcher.call(value)
      end
    end

    def find_method_or_expr
      s = statement
      case s
        when 'CDATA'                      # unparsed character data e.g. '<not-xml>'; may not contain string ']]>'
          proc do |val| val.match(CDATA_EXPR).nil? end
        when 'ID'       then ID_EXPR # does not check for uniqueness!
        when 'IDREF'                      # id of another doc
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
  end # module ValueRule
end # module Duxml