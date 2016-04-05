require File.expand_path(File.dirname(__FILE__) + '/guts')
module Dux
  module ObjectInterface
    include Comparable

    public
    # returns an array of this object's children that match the given type i.e. element name
    def find_children(type)
      a = []
      children.each do |child|
        a << child if child.type == type.to_s
      end
      a
    end

    # returns the first child matching a given pattern, which can be of types:
    # Fixnum - for child index
    # String - for both id or type
    # Symbol - for id
    # Array - allows application of one pattern per generation
    def find_child(child_pattern, cur_comp = nil)
      pattern = if child_pattern.is_a?(Array)
                  child_pattern.any? ? child_pattern.first : nil
                else
                  child_pattern
                end
      return nil unless pattern
      #attempting to match by name
      cur_comp ||= self
      #attempting to use pattern as index
      return cur_comp.children[pattern] if pattern.is_a?(Fixnum)
      cur_comp.children.each do |cur_child|
        if cur_child.name == pattern.to_s || cur_child.type == pattern.to_s
          if child_pattern == pattern || child_pattern.size == 1
            return cur_child
          else
            return find_child(child_pattern[1..-1], cur_child)
          end
        end
      end
      #attempting to use pattern as key
      if cur_comp.children_hash[pattern]
        cur_comp.children_hash[pattern]
      else
        find_child(child_pattern[1..-1]) if child_pattern.is_a?(Array)
      end
      nil
    end #def find_child

    # overriding TreeNode::content to point to XML head's content
    def content
      source = children.size == 1 && children.first.text? ? children.first : xml
      source.content
    end

    # returns id i.e. name that is unique among its siblings
    def id
      self[:id]
    end

    # shortcut for accessing XML attributes
    def [](attr=nil)
      attr.nil? ? xml.attributes : xml[attr.to_s]
    end

    # TODO assess if we need this - wasn't it just for debugging?
    def each(&block)
      super &block
    end

    # add a child from given object; method will attempt to coerce object into acceptable Dux::Object
    # allowable argument types include: XML represented as string, Nokogiri::XML::Element, an XML file, and Dux::Object
    def <<(obj)
      objs = obj.is_a?(Array) ? obj : [obj]
      objs.each do |node|
        new_kid = coerce node
        add new_kid
        @xml.add_child new_kid.xml if post_init?
        report :add, node if design_comp?
      end
      self
    end

    # removes a child matching the given child or id, returning self if successful, nil if not
    def remove(child_or_id)
      return if child_or_id.nil?
      child = child_or_id.respond_to?(:id) ? child_or_id : find_child(child_or_id)
      child.xml.remove
      remove! child
      report :remove, child if design_comp?
      self
    end

    # returns attributes as simple Hash
    def attributes
      h = {}
      xml.attributes.each do |attr|
        h[attr.first.to_sym] = attr.last.value
      end
      h
    end

    # change an attribute value
    def []=(key, val)
      change_attr_value key, val
      self
    end

    # TODO assess whether we really need this method
    def rename(new_id)
      old_id = id
      super new_id
      @xml[:id] = new_id
      report :change_attribute, {id: old_id} if design_comp?
      self
    end

    # TODO assess whether we should block user from using this to spawn children
    # changes content of this XML::Element
    def content=(new_content)
      change_type = content.empty? ? :new_content : :change_content
      old_content = content
      @xml.content = new_content
      report change_type, old_content
      self
    end

    # used for #respond_to?
    def is_component?
      true
    end

    # all Dux::Objects other than Dux::PCData represent XML elements are are therefore not text
    def text?
      false
    end

    # returns this object as a string representation of its XML in memory;
    # note that this differs XML on file as in memory, #PCDATA children are wrapped in a temporary element
    # <p_c_data>. compare to #xml
    def to_s
      xml.to_s
    end

    # returns type of object i.e. the xml element's name
    def type
      xml.name
    end

    # returns root of metadata
    def meta
      return root if root.type == 'meta'
      nil
    end

    # returns root of this XML document
    def xml_root
      meta.design.xml
    end


    # returns human-readable description of this object
    def description
      %(<#{type} id="#{id}">)
    end

    # returns true if this object is descended from an object of the target type or id
    def descended_from?(target)
      xml.ancestors.each do |ancestor|
        return true if ancestor.name == target.to_s
        return true if ancestor.type == target.to_s
      end
      false
    end


    # index position of this object among its siblings
    def position
      parent.children.each_with_index do |child, index|
        return index if child == self
      end
    end
  end # module ObjectInterface
end # module Dux
