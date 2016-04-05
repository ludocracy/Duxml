require File.expand_path(File.dirname(__FILE__) + '/pattern')

module Dux
  Struct.new 'Scanner', :match, :operator
  # do not use - must be subclassed!
  class Rule < Pattern
    @cur_object
    attr_reader :cur_object
    # can be initialized from XML Element or Ruby arguments
    # args[0] must be the subject (e.g. name of element or attribute)
    # args[1] must be the statement of the rule in Regexp/DTD form
    #
    # @cur_object can only be set by the Grammar as it validates a given Change or Pattern
    # it indicates the Object currently being inspected by this Rule
    def initialize(*args)
      super *args
      unless from_file? args
        @xml << args[1].gsub(/\s/, '')
        @xml.remove_attribute 'object'
      end
      @cur_object = nil
    end

    # Dux::Rule's #qualify is only used to report errors found by its subclasses' #qualify methods
    def qualify(change_or_pattern)
      type = (change_or_pattern.is_a?(Dux::Change)) ? :qualify_error : :validate_error
      report type, change_or_pattern
    end

    def description
      %(#{name} that #{relationship} of #{subject} must match #{statement})
    end

    # returns the DTD or Ruby code statement that embodies this Rule
    def statement
      xml.content
    end

    # subject of Rule is not an object but a type or
    # class simple name e.g. XML element or attribute name
    def subject
      self[:subject]
    end

    # object of Rule is nil but during #qualify can be the object matching type given by #subject
    # that is then being qualified
    def object
      self[:object]
    end
  end # class Rule
end # module Dux