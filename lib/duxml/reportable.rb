# Copyright (c) 2016 Freescale Semiconductor Inc.

require 'observer'

module Reportable
  include Observable

  # @param obs [Object] observer to add to this Element as well as its NodeSet
  def add_observer(obs, sym=nil)
    super(obs, sym || :update)
    nodes.add_observer(obs, sym || :update) if self.respond_to?(:nodes) and nodes.respond_to?(:add_observer)
  end

  attr_reader :observer_peers

  private

  # all public methods that alter XML must call #report in the full scope of that public method
  # in order to correctly acquire name of method that called #report
  #
  # @param *args [*several_variants]
  def report(*args)
    return nil if @observer_peers.nil?
    changed
    new_args = [args.first, self]
    args[1..-1].each do |a| new_args << a end if args.size > 1
    notify_observers(*new_args)
  end
end