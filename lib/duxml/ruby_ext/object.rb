require File.expand_path(File.dirname(__FILE__) + '/string')

class Object
  def simple_name
    self.class.to_s.split('::').last
  end

  def simple_module
    a = self.class.to_s.split('::')
    a.size > 1 ? a[-2] : 'Module'
  end
end