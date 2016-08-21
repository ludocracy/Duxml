# Copyright (c) 2016 Freescale Semiconductor Inc.

require File.expand_path(File.dirname(__FILE__) + '/change')

module Duxml
  module Add; end

  # created when an doc gains a child
  class AddClass < ChangeClass
    include Add

    def initialize(_subject, _child, _index)
      super _subject
      @child, @index = _child, _index
    end

    attr_reader :subject, :child, :index
    alias_method :parent, :subject
    alias_method :object, :child
  end

  module Add
    def description
      %(#{super} #{child.description} added to #{parent.description} at index #{index == -1 ? '0' : index.to_s}.)
    end

    def parent
      subject
    end
  end # class Add
end # module Duxml