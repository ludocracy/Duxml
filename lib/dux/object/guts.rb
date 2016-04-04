require 'observer'
require File.expand_path(File.dirname(__FILE__) + '/../ruby_ext/nokogiri')

module Dux
  module ObjectGuts
    include Observable
    private

    def coerce(obj)
      return obj if obj.respond_to?(:is_component?)
      x = obj.xml
      return Dux::PCData.new obj if x.nil?
      class_name = x.name.classify
      if Dux::constants.include?(class_name.to_sym)
        Dux::const_get(class_name).new x
      else
        Dux::const_set(class_name, Class.new(Dux::Object)).new x
      end
    end

    def design_comp?
      type == 'design' || descended_from?(:design)
    end

    def post_init?
      !caller.any? do |call| call.match(/(?:`)(.)+(?:')/).to_s[1..-2] == 'initialize' end
    end


    def class_to_xml(*args)
      if args.compact.size == 1 && !args.first.respond_to?(:is_component?) && !args.first.is_a?(Hash)
        args.first.xml
      else
        all_str_args = objects2ids args
        element self.simple_class, *all_str_args
      end
    end

    def new_id
      self.simple_class+object_id.to_s
    end

    def objects2ids(args)
      args.collect do |arg|
        if arg.is_a?(Hash)
          arg.each do |k, v|
            arg[k] = v[:id] || v.id if v.respond_to?(:element) || v.respond_to?(:is_component?)
          end
        else
          arg
        end
      end
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
          @xml_root_node[key] = val
          report change_type, {old_value: old_val, new_value: val, attr_name: key.to_s}
      end # case key
    end # def change_attr_value
  end # module ObjectGuts
end # module Dux