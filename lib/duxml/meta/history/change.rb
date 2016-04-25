require File.expand_path(File.dirname(__FILE__) + '/../grammar/pattern')

module Duxml
  module Change; end
  # do not use - only for subclassing
  # changes represent events i.e. patterns with a fixed position in time,
  # and can include qualification and validation errors
  class ChangeClass < PatternClass
    include Change

    @time_stamp

    # all subclasses of Change must call this super method or implement the same function within their #initialize
    #
    # @param _subject [Duxml::Element] parent doc affected by change
    def initialize(_subject, *args)
      super _subject
      @time_stamp = Time.now
      args.each do |arg|
        if arg.is_a?(Duxml::Element)
          @object = arg
          break
        end
      end
    end

    attr_reader :time_stamp
  end # class ChangeClass < PatternClass

  module Change
    def abstract?
      false
    end

    # @return [String] gives its time stamp
    def description
      "at #{time_stamp}#{line_expr}:"
    end

    # @return [-1,0,1,nil] compares dates of changes
    def <=>(obj)
      return nil unless obj.is_a?(Duxml::Change)
      date <=> obj.date
    end

    # @return [String] string equivalent of object's line number
    def line_expr
      case
        when object.respond_to?(:line) && object.line >= 0
          " on line #{object.line.to_s}"
        when object.respond_to?(:object) && object.object.respond_to?(:line) && object.object.line >= 0
          " on line #{object.object.line.to_s}"
        when subject.respond_to?(:line) && subject.line >= 0
          " on line #{subject.line.to_s}"
        else ''
      end
    end
  end # class Change
end # module Duxml