require File.expand_path(File.dirname(__FILE__) + '/reportable')

module Ox
  class NodeSet < Array
    include Reportable

    @parent

    attr_reader :parent
    def []=(index, str)
      old_str = self[index]
      super(index, str)
      report :ChangeText, parent, old_str
      self
    end

    def initialize(_parent, *args)
      super *args
      @parent = _parent
    end
  end
end