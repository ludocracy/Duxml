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

module Duxml
  module History; end

  class HistoryClass
    include History
  end

  module History
    include Enumerable
    include Reportable

    def self.xml
      Element.new('duxml:history').extend self
    end

    def grammar
      @observer_peers.first.first
    end

    def description
      "history follows: \n" +
      collect do |change_or_error|
        change_or_error.description
      end.join("\n")
    end

    # receives reports from interface of changes or from Duxml::Rule violations
    def update(type, *args)
      change_class = Duxml::const_get "#{type.to_s}Class".to_sym
      change_comp = change_class.new *args
      @nodes.unshift change_comp
      notify_observers change_comp unless change_comp.respond_to?(:error?)
    end
  end # module History
end # module Duxml