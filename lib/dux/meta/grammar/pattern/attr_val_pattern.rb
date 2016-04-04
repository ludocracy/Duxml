require File.expand_path(File.dirname(__FILE__) + '/../../grammar/pattern')

module Dux
  # pattern representing relationship between an object and its child
  class AttrValPattern < Pattern
    def relationship
      'attribute value'
    end
  end # class AttrValPattern
end # module Dux
