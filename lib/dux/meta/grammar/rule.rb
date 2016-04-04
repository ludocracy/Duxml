require File.expand_path(File.dirname(__FILE__) + '/pattern')

module Dux
  # do not use - must be subclassed!
  class Rule < Pattern
    # Dux::Rule's #qualify is only used to report errors found by its subclasses' #qualify methods
    def qualify(change_or_pattern)
      type = (change_or_pattern.is_a?(Dux::Change)) ? :qualify_error : :validate_error
      report type, change_or_pattern
    end

    def description
      %(#{id} which states: #{content})
    end

    private def class_to_xml *args
      return args.first.xml if args.first.xml
      xml_node = super *args
      xml_node.content = args.last.to_s.gsub(/[<>\s]/, '')
      xml_node.remove_attribute 'object'
      xml_node
    end

    # returns the DTD or Ruby code statement that embodies this Rule
    def statement
      self[:statement] || children.first.content
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

    private :class_to_xml
  end # class Rule
end # module Dux