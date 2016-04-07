require File.expand_path(File.dirname(__FILE__) + '/change')

module Duxml
  # do not use
  class Error < Change
    # returns rule from Grammar that found this Error
    def violated_rule
      root.grammar.find_child(self[:subject])
    end
  end # class Error
end # module Duxml