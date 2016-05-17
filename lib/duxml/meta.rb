# Copyright (c) 2016 Freescale Semiconductor Inc.

require File.expand_path(File.dirname(__FILE__) + '/meta/grammar')
require File.expand_path(File.dirname(__FILE__) + '/meta/history')
require File.expand_path(File.dirname(__FILE__) + '/saxer')

module Duxml
  module Meta

    FILE_EXT = '.duxml'
  end

  # all XML files ready by Duxml have a metadata file generated with a modified, matching file name
  # @see #Meta.meta_path
  class MetaClass
    include Meta

    # @param grammar_path [String] optional path of grammar file which can be a spreadsheet or Duxml::Grammar file
    def initialize(grammar_path=nil)
      @history = HistoryClass.new
      self.grammar = grammar_path ? Grammar.import(grammar_path) : GrammarClass.new
      @grammar_path = grammar_path
    end

    attr_reader :history, :grammar
  end

  module Meta
    # @return [Doc] metadata document
    def self.xml
      d = Doc.new << (Element.new(name.nmtokenize) << Grammar.xml << History.xml)
      d.root.grammar[:ref] = @grammar_path if @grammar_path
      d
    end

    # @return [String] name of metadata file based on content file's name e.g.
    #   'design.xml' => '.design.xml.duxml'
    def self.meta_path(path)
      dir = File.dirname(path)
      "#{dir}/.#{File.basename(path)}#{FILE_EXT}"
    end

    def grammar=(g)
      @grammar = g.is_a?(GrammarClass) ? g : Grammar.import(g)
      history.delete_observers
      history.add_observer(grammar, :qualify)
      grammar.add_observer history
    end
  end # module Meta
end # module Duxml