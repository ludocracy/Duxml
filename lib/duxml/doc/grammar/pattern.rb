require File.expand_path(File.dirname(__FILE__) + '/../../element')

module Duxml
  module Pattern
    @subject

    def simple_name
      name.split(':').last
    end

    def name
      c = self.class.to_s
      return c.nmtokenize unless c.include?('::')
      a =  c.split('::')
      a[-2..-1].collect do |word|
        word.nmtokenize
      end.join(':')
    end

    attr_reader :subject

    # returns relationship description as string by subtracting super class name
    # (e.g. 'pattern' or 'rule') from simple_class
    # Duxml::ChildrenRule#relationship => 'children'
    # Duxml::TextPattern#relationship => 'text'
    # can be overridden if class name does not match human-readable string
    # @return [String] single word to describe relationship of subject to object
    def relationship
      simple_name.split('_').first
    end

    # @return [String] "#{object.description} is #{relationship} of #{subject.description}"
    def description
      "#{object.description} is #{relationship} of #{subject.description}"
    end

    def object
      instance_variables.each do |var|
        target = instance_variable_get(var)
        return target if target.is_a?(Duxml::Element) && target != subject
      end
      nil
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