require File.expand_path(File.dirname(__FILE__) + '/../grammar/pattern')

module Duxml
  # TODO NOT IMPLEMENTED YET!!!
  module Undo; end

  # created when a previous change is undone
  class UndoClass < ChangeClass
    include Undo
  end

  module Undo
    def description
      "#{super} change '#{subject.id}' undone."
    end

    # returns previous change instance that was undone
    def undone_change
      self[:change]
    end
  end
end # module Duxml