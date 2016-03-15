require File.expand_path(File.dirname(__FILE__) + '/../../object')

module Dux
  class Pattern < Object
    def initialize subj, args = {}
      if subj.respond_to?(:is_component?)
        xml_node = class_to_xml args
        xml_node[:subject] = subj.id
      else
        xml_node = subj
      end
      super xml_node, args
    end

    def subject context_root=root
      resolve_ref :subject, context_root
    end

    def object context_root=root
      result = has_children? ? children.first : resolve_ref(:object, context_root)
      result
    end

    def <=> pattern
      return 1 unless pattern.respond_to?(:subject)
      case subject <=> pattern.subject
        when -1 then -1
        when 0 then object <=> pattern.object
        else -1
      end
    end

    def class_to_xml args={}
      xml_node = super()
      args.each do |k, v| xml_node[k] = v.respond_to?(:id) ? v.id : v end
      xml_node
    end

    private :class_to_xml
  end # class Pattern
end # module Dux