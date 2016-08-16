# Copyright (c) 2016 Freescale Semiconductor Inc.

require File.expand_path(File.dirname(__FILE__) + '/history/add')
require File.expand_path(File.dirname(__FILE__) + '/history/remove')
require File.expand_path(File.dirname(__FILE__) + '/history/validate_error')
require File.expand_path(File.dirname(__FILE__) + '/history/qualify_error')
require File.expand_path(File.dirname(__FILE__) + '/history/new_attr')
require File.expand_path(File.dirname(__FILE__) + '/history/change_attr')
require File.expand_path(File.dirname(__FILE__) + '/history/new_text')
require File.expand_path(File.dirname(__FILE__) + '/history/change_text')
require File.expand_path(File.dirname(__FILE__) + '/history/undo')
require File.expand_path(File.dirname(__FILE__) + '/../doc')
require 'forwardable'

module Duxml
  # monitors XML Elements for changes and GrammarClass for errors, recording them and saving to Meta file
  module History
    include Duxml
    include Reportable
  end

  # as an object, HistoryClass holds events latest first, earliest last
  # it also has delegators that allow the use of Array-style notation e.g. '[]' and #each to search the history.
  class HistoryClass
    include History
    extend Forwardable

    def_delegators :@nodes, :[], :each

    # @param strict_or_false [Boolean] by default strict i.e. true so that if this History detects an error it will raise an Exception; otherwise not
    def initialize(strict_or_false = true)
      @nodes = []
      @strict = strict_or_false
    end

    attr_reader :nodes
    alias_method :events, :nodes
  end

  module History
    # used when creating a new metadata file for a static XML file
    #
    # @return [Doc] returns self as XML document
    def xml
      h = Element.new('history')
      events.each do |event| h << event.xml end
      h
    end

    # @return [Boolean] toggles (true by default) whether History will raise exception or tolerate qualify errors
    def strict?(strict_or_false=nil)
      @strict = strict_or_false.nil? ? @strict : strict_or_false
    end

    # @return [ChangeClass, ErrorClass] the latest event
    def latest
      events[0]
    end

    # @return [GrammarClass] grammar that is observing this history's events
    def grammar
      @observer_peers.first.first if @observer_peers and @observer_peers.any? and @observer_peers.first.any?
    end

    # @return [String] shortened self description for debugging
    def inspect
      "#<#{self.class.to_s} #{object_id}: @events=#{nodes.size}>"
    end

    # @return [String] returns entire history, calling #description on each event in chronological order
    def description
      "history follows: \n" +
      events.reverse.collect do |change_or_error|
        change_or_error.description
      end.join("\n")
    end

    # @param type [Symbol] category i.e. class symbol of changes/errors reported
    # @param *args [*several_variants] information needed to accurately log the event; varies by change/error class
    def update(type, *args)
      change_class = Duxml::const_get "#{type.to_s}Class".to_sym
      change_comp = change_class.new *args
      @nodes.unshift change_comp
      changed
      notify_observers(change_comp) unless change_comp.respond_to?(:error?)
      raise(Exception, change_comp.description) if strict? && type == :QualifyError
    end
  end # module History
end # module Duxml