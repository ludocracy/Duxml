require File.expand_path(File.dirname(__FILE__) + '/change')

module Dux
  # created when an object gains a child
  class Add < Change
    def description
      super || %(Element '#{added.id}' of type '#{added.type}' was added to element '#{subject.id}' of type '#{subject.type}'.)
    end

    def added
      resolve_ref :object, root
    end
  end
end