require File.expand_path(File.dirname(__FILE__) + '/change')

module Duxml
  module Error; end

  # do not use
  class ErrorClass < ChangeClass
    include Error
  end

  module Error
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