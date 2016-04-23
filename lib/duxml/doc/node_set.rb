require 'observer'

module Duxml
  class NodeSet < Array
    include Observable

    @parent

    attr_reader :parent

    def initialize(_parent, *args)
      super *args
      @parent = _parent
    end

    def history
      @observer_peers.first.first if @observer_peers and @observer_peers.first.any?
    end

    def []=(index, str)
      raise Exception if count_observers < 1
      old_str = self[index]
      super(index, str)
      changed
      notify_observers(:ChangeText, parent, index, old_str)
      self
    end
  end # class NodeSet < Array
end # module Duxml