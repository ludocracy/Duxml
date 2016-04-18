require File.expand_path(File.dirname(__FILE__) + '/class')
require File.expand_path(File.dirname(__FILE__) + '/string')

class Object
  # @return [String] returns name of class without Module hierarchy
  def simple_class
    self.class.simple_class
  end

  # @return [String] returns name of class's module without its hierarchy
  def simple_module
    self.class.simple_module
  end
end