require File.expand_path(File.dirname(__FILE__) + '/../../object')

module Dux
  class Pattern < Object
    private def class_to_xml *args
              return args.first.xml if args.first.xml && args.first.respond_to?(:element?)
      if args.any? do |arg| arg.is_a?(Hash) end
        super *args
      else
        h = Hash.new
        h[:subject] = args.first if args.first
        h[:object] = args.last if args.size > 1
        super h
      end
    end

    # subject of pattern; almost always the superior object in the relationship, e.g. parent object
    def subject(context_root=root)
      resolve_ref(:subject, context_root) || self[:subject]
    end

    # object of pattern; almost always the inferior object in the relationship, e.g. child object
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
end # module Dux