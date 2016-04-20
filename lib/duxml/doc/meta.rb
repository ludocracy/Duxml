require File.expand_path(File.dirname(__FILE__) + '/../../duxml/element')
require File.expand_path(File.dirname(__FILE__) + '/history')
require File.expand_path(File.dirname(__FILE__) + '/grammar')

module Duxml
  module Meta
    def self.xml
      Ox::Element.new('duxml:meta') << Grammar.xml << History.xml
    end
  end
end