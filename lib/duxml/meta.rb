require File.expand_path(File.dirname(__FILE__) + '/../duxml/ox_ext/element')

module Duxml
  module Meta
    include Ox
    class << self
      def xml
        e = Element.new('meta')
        e << '<history/><grammar/>'
      end
    end
    extend self
  end
end