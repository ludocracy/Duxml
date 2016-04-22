class Module
  def simple_name
    self.to_s.split('::').last
  end

  def simple_module
    a = self.to_s.split('::')
    a.size > 1 ? a[-2] : 'Module'
  end
end