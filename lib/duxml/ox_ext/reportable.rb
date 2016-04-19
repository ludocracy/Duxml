require 'observer'

module Reportable
  include Observable

  private

  # all public methods that alter XML must call #report in the full scope of that public method
  # in order to correctly acquire name of method that called #report
  #
  # @param *args [*several_variants]
  def report(*args)
    return if count_observers < 1
    changed
    notify_observers *args.flatten
  end
end
