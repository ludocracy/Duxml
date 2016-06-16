# Copyright (c) 2016 Freescale Semiconductor Inc.

require 'observer'

module Duxml
  # subclass of Array that is Observable by History
  # used to track changes in String nodes of XML Element
  class NodeSet < Array
    include Observable

    @parent

    attr_reader :parent

    # @param _parent [Element] Element that is parent to this NodeSet's elements
    # @param ary [[String, Element]] child nodes with which to initialize this NodeSet
    def initialize(_parent, ary=[])
      super ary
      @parent = _parent
    end

    # @return [HistoryClass] object that observes this NodeSet for changes
    def history
      @observer_peers.first.first if @observer_peers and @observer_peers.first.any?
    end

    # @param index [Fixnum] index of array where old String is to be replaced
    # @param str [String] replacing String
    # @return [self] reports old String and index to history
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