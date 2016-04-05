require File.expand_path(File.dirname(__FILE__) + '/../grammar/pattern')

module Dux
  # do not use - only for subclassing
  # changes represent events i.e. patterns with a fixed position in time,
  # and can include qualification and validation errors
  class Change < Pattern
    def initialize(*args)
      super *args
      @xml[:date] = Time.now.to_s unless xml?(args)
    end

    def description
      descr = find_child(:description)
      descr.nil? ? nil : descr.content
    end

    # returns date and time of change
    def date
      self[:date]
    end

    # change subject is always an object
    def subject(context_dux=nil)
      resolve_ref :subject, (context_dux || meta)
    end
  end # class Change

  # created when a previous change is undone
  class Undo < Change
    def description
      super || "#{subject.id} undone."
    end

    # returns previous change instance that was undone
    def undone_change
      self[:change]
    end
  end
end # module Dux