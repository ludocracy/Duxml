require File.expand_path(File.dirname(__FILE__) + '/meta/grammar')
require File.expand_path(File.dirname(__FILE__) + '/meta/history')

module Duxml
  module Meta
    include Duxml
  end

  class MetaClass
    include Meta

    def initialize
      @grammar, @history = Grammar.new, History.new
    end
  end

  module Meta

  end
end