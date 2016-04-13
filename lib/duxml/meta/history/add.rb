require File.expand_path(File.dirname(__FILE__) + '/change')

module Duxml
  # created when an object gains a child
  class Add < Change
    def description
      super || %(#{added.description} was added to #{subject.description}.)
    end

    # returns object that was added
    def added(context_root=root)
      resolve_ref :object, context_root
    end
  end # class Add
end # module Duxml