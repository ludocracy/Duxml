require File.expand_path(File.dirname(__FILE__) + '/../duxml/ox_ext/element')

module Duxml
  module Meta
    include Ox
    class << self
      def xml
        Element.new('meta') << '<grammar/>' << '<history/>'
      end
    end
    extend self
  end
end