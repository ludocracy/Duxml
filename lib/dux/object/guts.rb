require 'observer'
require File.expand_path(File.dirname(__FILE__) + '/../ruby_ext/nokogiri')

module Dux
  module ObjectGuts
    include Observable
    private

    attr_reader :xml_cursor, :reserved_word_array

    # loads methods to run during initialize from a hash
    def exec_methods method_names
      method_hash = {}
      index = 0
      %w(top reserved traverse).each do |key|
        method_name = method_names[index]
        if method_name
          our_method = method(method_names[index].to_sym)
        else
          our_method = method(:do_nothing)
        end
        method_hash[key.to_sym] = our_method
        index += 1
      end
      method_hash
    end

    # needed because i have to call a method and it has to have an argument
    def do_nothing arg = nil
      # this is silly
    end

    # run by initialize
    def traverse_xml method_hash
      method_hash[:top].call
      xml_cursor.element_children.each do |child|
        if reserved_word_array.include? child.name
          method_hash[:reserved].call child
        else
          method_hash[:traverse].call child
        end
      end
    end

    def init_reserved child
      child_class = Dux::const_get(child.name.classify)
      self << child_class.new(child, reserved: reserved_word_array)
    end

    def init_generic child
      self << Dux::Object.new(child, reserved: reserved_word_array)
    end

    def xml=arg
      @xml_cursor=arg
    end

    def coerce obj
      case obj.class
        when String                                       then Dux::Object.new(Nokogiri::XML(obj).root)
        when Nokogiri::XML::Element                       then Dux::Object.new(obj)
        when obj.respond_to?(:document?) && obj.document? then Dux::Object.new(obj.root)
        else obj
      end
    end

    def design_comp?
      type == 'design' || descended_from?(:design)
    end

    def post_init?
      !caller.any? do |call| call.match(/(?:`)(.)+(?:')/).to_s[1..-2] == 'initialize' end
    end


    def class_to_xml args={}
      element self.simple_class, {id: self.simple_class+object_id.to_s}
    end

    def resolve_ref attr, context_template=nil
      ref = self[attr.to_sym]
      return nil if ref.nil?
      if context_template.nil?
        Dux::Object.new File.open ref if File.exists?(ref)
      else
        context_template.find ref
      end
    end

    def report type, obj
      if post_init? || respond_to?(:qualify)
        add_observer meta.history if meta && count_observers == 0
        changed
        h = {subject: self, object: obj}
        notify_observers type, h
      end
    end

    def change_attr_value key, val
      case key
        when :id, :if then return
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
      end
    end
  end # module ObjectGuts
end # module Dux