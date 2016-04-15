require File.expand_path(File.dirname(__FILE__) + '/error')

module Duxml
  # created when grammar detects error from file
  class ValidateError < Error
    # @param *args [*several_variants] if args.first is not XML,
    #   args[0] must be violated Rule,
    #   args[1] must be violating Pattern
    def initialize(*args)
      if xml? args
        super *args
      else
        raise Exception if args.size != 2
        super({subject: args.first}, args.last.xml)
      end
    end

    # returns object that is parent of the pattern e.g. the parent of a child node, the parent of the attribute, etc.
    def affected_parent
      object.subject
    end

    def description
      "#{simple_class.gsub('_', ' ')} at line #{error_line_no}: #{non_compliant_change.description} which violates rule #{violated_rule.description}."
    end

    # returns Duxml::Pattern that was found to be in error
    def non_compliant_change
      children.first
    end

    # returns XML file line number of error causing object (or subject if no object exists)
    def error_line_no
      non_compliant_change.object.respond_to?(:line) ? non_compliant_change.object.line : non_compliant_change.subject.line
    end
  end # class ValidateError
end # module Duxml