require File.expand_path(File.dirname(__FILE__) + '/../../grammar/pattern')

module Duxml
  # pattern representing relationship between an object and its child
  class ChildPattern
    include Pattern

    # @param _subject [Ox::Element] parent of child
    # @param _index [Fixnum] index of child
    def initialize(_subject, _index)
      @subject, @index = _subject, _index
    end

    attr_reader :subject, :index

    def child
      affected_parent.nodes[index]
    end

    # @return [String] describes relationship between parent and child
    def relationship
      "#{super} ##{object.position+1}"
    end

    alias_method :affected_parent, :subject

    # @param context_root [Duxml::Meta] context in which pattern subject/object are to be evaluated
    # @return [Boolean] whether this pattern refers to actual objects or is hypothetical e.g. object is nil or is name of a Duxml#simple_class
    def abstract?(context_root=meta)
      object.nil? || Duxml::const_defined?(object.to_s.classify)
    end

    # @return [String] description of this child pattern
    def description
      return super unless abstract?
      ph = object.nil? ? ' has no children' : " is missing <#{self[:object]}>"
      "#{affected_parent.description} #{ph}"
    end
  end # class ChildPattern
end # module Duxml
