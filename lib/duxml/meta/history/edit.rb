require File.expand_path(File.dirname(__FILE__) + '/change')

module Duxml
  # do not use; for subclassing
  # represents changes to XML not affecting tree structure
  class Edit < Change; end
end # module Duxml