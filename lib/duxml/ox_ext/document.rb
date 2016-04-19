require File.expand_path(File.dirname(__FILE__) + '/../../../lib/duxml/ox_ext/element')

module Ox
  class Document < Element
    def initialize(prolog={})
      super(nil)
      @attributes = { }
      @attributes[:version] = prolog[:version] unless prolog[:version].nil?
      @attributes[:encoding] = prolog[:encoding] unless prolog[:encoding].nil?
      @attributes[:standalone] = prolog[:standalone] unless prolog[:standalone].nil?
      @grammar = prolog[:grammar] if prolog[:grammar]
      @history = prolog[:history] if prolog[:history]
      @history.add_observer grammar
      register_nodes
    end

    attr_reader :history, :grammar

    private

    def register_nodes
      traverse do |node| node.add_observer history end
    end
  end
end