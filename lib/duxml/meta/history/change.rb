require File.expand_path(File.dirname(__FILE__) + '/../grammar/pattern')

module Duxml
  # do not use - only for subclassing
  # changes represent events i.e. patterns with a fixed position in time,
  # and can include qualification and validation errors
  class Change < Pattern
    # can be initialized from XML or from Ruby args
    # arguments follow default Duxml::Pattern#initialize format
    # this method will timestamp the Change if it is new
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
end # module Duxml