require File.expand_path(File.dirname(__FILE__) + '/change')

module Dux
  class Remove < Change
    def class_to_xml args={}
      super(args) << args[:object].xml
    end

    def description
      super ||
          %(Element '#{removed.id}' of type '#{removed.type}' was removed from element '#{subject.id}' of type '#{subject.type}'.)
    end

    def removed
      object
    end
  end
end