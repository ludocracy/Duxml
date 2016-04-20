module Duxml
  module Pattern
    @subject

    attr_reader :subject

    # @param context_root [Duxml::Meta] context_root is the root for the Duxml::Element tree in which this object can be found since Duxml::Pattern
    #   this value must normally be provided if pattern is not part of object's tree
    # @return [Boolean] whether or not both subject and object are concrete i.e. can be resolved to actual Duxml::Element
    def abstract?(doc)
      false
      #!(subject(context_root).respond_to?(:is_component?) && object(context_root).respond_to?(:is_component?))
    end

    # returns relationship description as string by subtracting super class name
    # (e.g. 'pattern' or 'rule') from simple_class
    # Duxml::ChildrenRule#relationship => 'children'
    # Duxml::ContentPattern#relationship => 'content'
    # can be overridden if class name does not match human-readable string
    # @return [String] single word to describe relationship of subject to object
    def relationship
      name[0..-(super_class_size+2)]
    end

    # @return [String] "#{object.description} is #{relationship} of #{subject.description}"
    def description
      "#{object.description} is #{relationship} of #{subject.description}"
    end

    # @param context_root [Duxml::Meta] context_root is the root for the Duxml::Element tree in which this object can be found since Duxml::Pattern
    #   this value must normally be provided if pattern is not part of object's tree
    # @return [Duxml::Element, String] subject of pattern; almost always the superior object in the relationship, e.g. parent object
    def subject(context_root=root)
      resolve_ref(:subject, context_root) || self[:subject]
    end

    # @param context_root [Duxml::Meta] context_root is the root for the Duxml::Element tree in which this object can be found since Duxml::Pattern
    #   this value must normally be provided if pattern is not part of object's tree
    # @return [Duxml::Element] object of pattern; almost always the inferior object in the relationship, e.g. child object
    def object(context_root=root)
      has_children? ? children.first : resolve_ref(:object, context_root)
    end

    # @param pattern [Duxml::Pattern] pattern or any subclass object
    # @return [Fixnum] first applies <=> to subjects, and if equal, applies <=> to objects
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