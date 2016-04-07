require File.expand_path(File.dirname(__FILE__) + '/../../object')

module Duxml
  class Pattern < Object
    # Duxml::Patterns can be initialized from XML or from arguments that are interpreted as follows:
    # args[0] must be the subject of the Pattern
    # args[1] must be the object of the Pattern
    # args[2] can be the relationship type of the Pattern
    # the first two arguments ids or names become attributes and the third becomes the content
    def initialize(*args)
      if args.empty? || xml?(args) || args.any? do |arg| arg.is_a?(Hash) end
        class_to_xml *args
      else
        h = Hash.new
        h[:subject] = args.first if args.first
        h[:object] = args[1] if args.size > 1
        content = args.size > 2 ? args[2] : nil
        class_to_xml h, content
      end
      super()
    end

    # returns relationship description as string by subtracting super class name
    # (e.g. 'pattern' or 'rule') from simple_class
    # Duxml::ChildrenRule#relationship => 'children'
    # Duxml::ContentPattern#relationship => 'content'
    # can be overridden if class name does not match human-readable string
    def relationship
      super_class_size = self.class.superclass.to_s.split('::').last.size
      simple_class[0..-(super_class_size+2)]
    end

    def description
      "#{object.description} is #{relationship} of #{subject.description}"
    end

    # subject of pattern; almost always the superior object in the relationship, e.g. parent object
    def subject(context_root=root)
      resolve_ref(:subject, context_root) || self[:subject]
    end

    # object of pattern; almost always the inferior object in the relationship, e.g. child object
    # context_root is the root for the Duxml::Object tree in which this object can be found since Duxml::Pattern
    # objects do not exist in a tree context, this value must normally be provided
    def object context_root=root
      has_children? ? children.first : resolve_ref(:object, context_root) || self[:object]
    end

    def <=>(pattern)
      return 1 unless pattern.respond_to?(:subject)
      case subject <=> pattern.subject
        when -1 then
          -1
        when 0 then
          object <=> pattern.object
        else
          -1
      end
    end # def <=>
  end # class Pattern
end # module Duxml