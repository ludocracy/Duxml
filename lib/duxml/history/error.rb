require File.expand_path(File.dirname(__FILE__) + '/change')

module Duxml
  # do not use
  class Error < Change
    # returns rule from Grammar that found this Error
    def violated_rule
      result = root.grammar.find_child(self[:subject])
      raise Exception if result.nil?
      result
    end

    def error?
      true
    end
  end # class Error
end # module Duxml