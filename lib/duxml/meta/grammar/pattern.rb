# Copyright (c) 2016 Freescale Semiconductor Inc.

require File.expand_path(File.dirname(__FILE__) + '/../../ruby_ext/string')

module Duxml
  module Pattern; end

  class PatternClass
    include Pattern
    @subject

    def initialize(subj)
      @subject = subj
    end

    attr_reader :subject
  end

  module Pattern
    include Duxml

    # @return [String] nmtoken name of this pattern without namespace prefix e.g. ChildPattern.new(parent, child).name => 'child_pattern'
    def simple_name
      name.split(':').last
    end

    # @return [Boolean] if either subject or object points to a name/type i.e. not an Element
    def abstract?
      subject.is_a?(String) or object.nil?
    end

    # @return [Boolean] if both subject and at least one object point to an actual XML Element
    def concrete?
      !abstract?
    end

    # @return [String] nmtoken name of this pattern e.g. ChildPattern.new(parent, child).name => 'duxml:child_pattern'
    def name
      c = self.class.to_s
      return c.nmtokenize unless c.include?('::')
      a =  c.split('::')
      a[-2..-1].collect do |word|
        word.nmtokenize
      end.join(':')
    end

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
      return @object if instance_variable_defined?(:@object)
      instance_variables.each do |var|
        target = instance_variable_get(var)
        return target unless target.is_a?(String) or target == subject
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
  end # module Pattern
end # module Duxml