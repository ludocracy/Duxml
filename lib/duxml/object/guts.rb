require 'observer'
require File.expand_path(File.dirname(__FILE__) + '/../ruby_ext/nokogiri')
require File.expand_path(File.dirname(__FILE__) + '/../object/p_c_data')

module Duxml
  module ObjectGuts
    include Observable
    private

    def coerce(obj)
      return obj if obj.respond_to?(:is_component?)
      x = obj.xml
      return Duxml::PCData.new obj if x.nil?
      class_name = x.name.classify
      if Duxml::constants.include?(class_name.to_sym)
        Duxml::const_get(class_name).new x
      else
        Duxml::const_set(class_name, Class.new(Duxml::Object)).new x
      end
    end

    def design_comp?
      m = xml.document.root.name
      m != 'meta'
    end

    def post_init?
      !caller.any? do |call| call.to_s.include?('initialize') end
    end

    # returns false if args.first is a Nokogiri::XML::Element or a string that can initialize one
    # returns true if args are Ruby arguments that need to have new corresponding XML created
    # either way, @xml is initialized
    def class_to_xml(*args)
      return false if args.empty?
      if xml? args
        @xml = args.first.xml
        false
      else
        all_str_args = objects2ids args
        @xml = element self.simple_class, *all_str_args
        true
      end
    end

    def xml?(args)
      args.compact.size == 1 && !args.first.respond_to?(:is_component?) && !args.first.is_a?(Hash)
    end

    def objects2ids(args)
      new_args = args.clone.compact
      new_args.each_with_index do |arg, index|
        if arg.is_a?(Hash)
          new_arg = arg.clone
          new_arg.each do |k, v|
            new_arg[k] = v[:id] || v.id if v.respond_to?(:element) || v.respond_to?(:is_component?)
          end
          new_args[index] = new_arg
        end
      end
      new_args
    end # def objects2ids

    def resolve_ref(attr, context_template=nil)
      ref = self[attr.to_sym]
      return nil if ref.nil?
      if context_template.nil?
        File.open(ref) if File.exists?(ref)
      else
        context_template.find ref
      end
    end

    def report(type, obj)
      if post_init? || respond_to?(:qualify)
        add_observer meta.history if meta && count_observers == 0
        changed
        h = {subject: self, object: obj}
        notify_observers type, h
      end
    end

    def change_attr_value(key, val)
      case key
        when :id, :if then
          return
        else
          old_val = if self[key]
                      change_type = :change_attribute
                      self[key]
                    else
                      change_type = :new_attribute
                      :nil
                    end
          @xml[key] = val
          report change_type, {old_value: old_val, new_value: val, attr_name: key.to_s}
      end # case key
    end # def change_attr_value
  end # module ObjectGuts
end # module Duxml