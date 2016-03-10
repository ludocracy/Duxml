require File.expand_path(File.dirname(__FILE__) + '/../grammar/pattern')

module Dux
  class Change < Pattern
    def class_to_xml args={}
      xml_node = super args
      xml_node[:date] = Time.now.to_s
      xml_node
    end

    def description
      descr = find_child(:description)
      descr.nil? ? nil : descr.content
    end

    def date
      self[:date]
    end

    def subject context_dux=nil
      resolve_ref :subject, context_dux || meta
    end

    def base_dux
      root
    end
  end # class Change

  class Undo < Change
    def description
      super || "#{subject.id} undone."
    end

    def undone_change
      self[:change]
    end
  end
end # module Dux