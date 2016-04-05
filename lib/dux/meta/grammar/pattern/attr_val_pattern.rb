require File.expand_path(File.dirname(__FILE__) + '/../../grammar/pattern')

module Dux
  # pattern representing relationship between an object and its child
  class AttrValPattern < Pattern
    def relationship
      'attribute value'
    end

    def description
      "#{object} is #{relationship} of @#{subject}"
    end
  end # class AttrValPattern
end # module Dux
