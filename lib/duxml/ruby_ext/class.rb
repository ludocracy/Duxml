class Class
  # shortcut for getting just class name
  #
  #   Maudule::KlassEx.simple_class => 'KlassEx'
  #
  # @return [String] name of class without module name base
  def simple_class
    to_s.split('::').last
  end

  #   module Maudule
  #     class Klass; end
  #   end
  #
  #   k = Maudule::Klass.new
  #   k.module_name       => 'Maudule'
  #   String.module_name  => 'Module'
  #
  # @return [String] name of this class's module
  def simple_module
    a = to_s.split('::')
    a.size > 1 ? a[-2] : 'Module'
  end
end