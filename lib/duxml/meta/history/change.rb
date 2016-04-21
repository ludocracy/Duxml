require File.expand_path(File.dirname(__FILE__) + '/../grammar/pattern')

module Duxml
  # do not use - only for subclassing
  # changes represent events i.e. patterns with a fixed position in time,
  # and can include qualification and validation errors
  class Change
    include Pattern

    @time_stamp

    # all subclasses of Change must call this super method or implement the same function within their #initialize
    #
    # @param _subject [Duxml::Element] parent doc affected by change
    def initialize(_subject, *args)
      @subject = _subject
      @time_stamp = Time.now
      args.each do |arg|
        if arg.is_a?(Duxml::Element)
          @object = arg
          break
        end
      end
    end

    def abstract?
      false
    end

    attr_reader :time_stamp

    # @return [String] gives its time stamp
    def description
      "at #{time_stamp}"
    end

    # @return [-1,0,1,nil] compares dates of changes
    def <=>(obj)
      return nil unless obj.is_a?(Duxml::Change)
      date <=> obj.date
    end
  end # class Change
end # module Duxml