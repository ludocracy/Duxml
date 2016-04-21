require File.expand_path(File.dirname(__FILE__) + '/../reportable')

module Duxml
  class NodeSet < Array
    include Reportable

    @parent

    attr_reader :parent

    def initialize(_parent, *args)
      super *args
      @parent = _parent
    end

    def []=(index, str)
      old_str = self[index]
      super(index, str)
      report(:ChangeText, parent, index, old_str)
      self
    end
  end # class NodeSet < Array
end # module Duxml