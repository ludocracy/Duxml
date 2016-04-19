require 'observer'
require File.expand_path(File.dirname(__FILE__) + '/history/add')
require File.expand_path(File.dirname(__FILE__) + '/history/remove')
require File.expand_path(File.dirname(__FILE__) + '/history/validate_error')
require File.expand_path(File.dirname(__FILE__) + '/history/qualify_error')
require File.expand_path(File.dirname(__FILE__) + '/history/new_attribute')
require File.expand_path(File.dirname(__FILE__) + '/history/change_attribute')
require File.expand_path(File.dirname(__FILE__) + '/history/new_content')
require File.expand_path(File.dirname(__FILE__) + '/history/change_content')
require File.expand_path(File.dirname(__FILE__) + '/history/undo')

module Duxml
  class History < Array
    include Observable

    def description
      "history follows: \n" +
      collect do |change_or_error|
        change_or_error.description
      end.join("\n")
    end

    # receives reports from interface of changes or from Duxml::Rule violations
    def update(type, *args)
      change_class = Duxml::const_get type
      change_comp = change_class.new *args
      shift change_comp
      notify_observers change_comp
    end
  end # class History
end # module Duxml