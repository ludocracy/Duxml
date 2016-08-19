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

    attr_reader :history, :grammar, :grammar_path
  end

  module Meta
    # @param path [String] path of XML-content file
    # @return [String] full path of metadata file based on content file's name e.g.
    #   'design.xml' => '.design.xml.duxml'
    def self.meta_path(path)
      dir = File.dirname(path)
      "#{dir}/.#{File.basename(path)}#{FILE_EXT}"
    end

    # @param g [String, GrammarClass] either a grammar object or path to one
    # @return [GrammarClass] grammar object
    def grammar=(g)
      @grammar = case g
                   when GrammarClass then g
                   when String
                     if File.exists?(g)
                       @grammar_path = g
                       Grammar.import(g)
                     else
                       maudule, meth = *g.split('.')
                       if Module.const_defined?(maudule.to_sym)
                         Module.const_get(maudule.to_sym).send(meth.to_sym)
                       else
                         raise ArgumentError, "#{g.to_s} is not a valid module/grammar symbol"
                       end
                     end
                   else
                     raise ArgumentError, "#{g.to_s} is not a valid Grammar or path to one"
                 end
      history.delete_observers if history.respond_to?(:delete_observers)
      history.add_observer(grammar, :qualify)
      grammar.add_observer history
      grammar
    end

    def xml
      if grammar_path
        g = Duxml::Element.new('grammar')
        g[:ref] = grammar_path
      else
        g = grammar.xml
      end
      Duxml::Element.new('meta') << g << history.xml
    end
  end # module Meta
end # module Duxml