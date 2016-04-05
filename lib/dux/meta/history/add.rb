require File.expand_path(File.dirname(__FILE__) + '/change')

module Dux
  # created when an object gains a child
  class Add < Change
    def description
      super || %(#{added.description} was added to #{subject.description}.)
    end

    def added
      resolve_ref :object, root
    end
  end
end