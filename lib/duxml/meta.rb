require File.expand_path(File.dirname(__FILE__) + '/meta/grammar')
require File.expand_path(File.dirname(__FILE__) + '/meta/history')

module Duxml
  module Meta
    include Duxml
    def self.xml
      Element.new('duxml:meta') << Grammar.xml << History.xml
    end
  end
end