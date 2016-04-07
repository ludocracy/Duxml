require File.expand_path(File.dirname(__FILE__) + '/guts')

module Duxml
  module ObjectInterface
    include Comparable

    public
    # returns an array of this object's children that match the given type(s) i.e. element name
    #
    # @param *types [several_variants] can be one or more element names e.g. Duxml::Object types
    # @return [Array[Duxml::Object]] array of children that match
    def find_children(*types)
      a = []
      children.each do |child|
        a << child if types.include?(child.type.to_sym) || types.include?(child.type)
      end
      a
    end

    # returns the first child matching a given pattern, which can be of types:
    # Fixnum - for child index
    # String - for both id or type
    # Symbol - for id
    # Array - allows application of one pattern per nesting level to find descendants of children
    # @param child_pattern [Fixnum|String|Symbol|Array] pattern for finding a given child
    # @param cur_obj [Duxml::Object] object whose descendant we are searching for; self by default, but only for first recursion
    # @return [Duxml::Object] found descendant; cannot be Duxml::PCData i.e. XML::Text node!
    def find_child(child_pattern, cur_obj = nil)
      pattern_array = case
                        when child_pattern.is_a?(Array)
                          child_pattern.clone
                        when child_pattern.is_a?(Fixnum) || child_pattern.to_s.gsub('-','_').identifier?
                          [child_pattern]
                        else
                          child_pattern.split(' ')
                      end
      cur_obj ||= self
      pattern = pattern_array.shift
      return pattern unless pattern
      #attempting to use pattern as index
      return cur_obj.children[pattern] if pattern.is_a?(Fixnum)
      cur_obj.children.each do |cur_child|
        if cur_child.name == pattern.to_s || cur_child.simple_class == pattern.to_s
          if pattern_array.empty?
            return cur_child
          else
            return find_child(pattern_array, cur_child)
          end
        end
      end
      #attempting to use pattern as key
      cur_obj.children_hash[pattern]
    end #def find_child

    # overriding TreeNode::content to point to XML head's content
    # @return [String] text content whether it contains XML or not
    def content
      source = children.size == 1 && children.first.text? ? children.first : xml
      source.content
    end

    # @return [String] id i.e. name that is unique among its siblings
    def id
      self[:id]
    end

    # shortcut for accessing XML attributes
    # @param attr [String|Symbol] desired attribute
    # @return [String|Hash] attribute value or if no attr given, all attributes as a Hash
    def [](attr=nil)
      attr.nil? ? attributes : xml[attr.to_s]
    end

    # TODO assess if we need this - wasn't it just for debugging?
    # TODO it's possible that this was needed in order for the build process to pick up our modification of Tree::TreeNode#each
    def each(&block)
      super &block
    end

    # add a child from given object; method will attempt to coerce object into acceptable Duxml::Object
    # allowable argument types include: XML represented as string, Nokogiri::XML::Element, an XML file, and Duxml::Object
    # @param obj [Duxml::Object|Nokogiri::XML::Node|String] object to be added can be Object, XML, XML as String or text content
    # @return [Duxml::Object] self
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
    # @param child_or_id [Duxml::Object|String|Symbol] can either be object to be removed itself or id of object to be removed
    # @return [Duxml::Object|nil] self if successful, nil if not; removed Object itself is moved to Duxml::History in metadata
    def remove(child_or_id)
      return if child_or_id.nil?
      child = child_or_id.respond_to?(:id) ? child_or_id : find_child(child_or_id)
      child.xml.remove
      remove! child
      report :remove, child if design_comp?
      self
    end

    # @return [Hash] attributes as simple Hash
    def attributes
      h = {}
      xml.attributes.each do |attr|
        h[attr.first.to_sym] = attr.last.value
      end
      h
    end

    # @param key [Symbol|String] change given attribute
    # @param val [Symbol|String|Fixnum|Float|Boolean] set to this value
    # @return [Duxml::Object] self
    def []=(key, val)
      change_attr_value key, val
      self
    end

    # TODO assess whether we really need this method
    # it appears to have some use if there is an ID collision between two genuinely different nodes
    # @param new_id [String|Symbol] change id to given value
    def rename(new_id)
      old_id = id
      super new_id
      @xml[:id] = new_id
      report :change_attribute, {id: old_id} if design_comp?
      self
    end

    # TODO assess whether we should block user from using this to spawn children
    # @param new_content [String] changes content of this Object to new_content
    # @return [Duxml::Object] self
    def content=(new_content)
      return nil unless xml.content.empty? || children.size == 1 && children.first.text?
      if children.size == 1 && children.first.text?
        change_type = :change_content
        old_content = content
        children.first.content = new_content
      elsif xml.content.empty?
        change_type = :new_content
        @xml.content = new_content
      else
        return nil
      end
      report change_type, old_content || nil
      self
    end

    # used for #respond_to?
    #
    # @return [TrueClass] always returns true
    def is_component?
      true
    end

    # all Duxml::Objects other than Duxml::PCData represent XML elements are are therefore not text
    #
    # @return [FalseClass] always returns false
    def text?
      false
    end

    # returns this object as a string representation of its XML in memory;
    # note that this differs XML on file as in memory, #PCDATA children are wrapped in a temporary element
    # <p_c_data>. compare to #xml
    def to_s
      xml.to_s
    end

    # @return [String] type of object i.e. the xml element's name
    def type
      xml.name
    end

    # @return [Duxml::Meta] root of metadata
    def meta
      return root if root.type == 'meta'
      nil
    end

    # @return [Nokogiri::XML::Element] root element of this XML document
    def xml_root
      meta.design.xml
    end


    # @return [String] human-readable description of this object
    def description
      %(<#{type} id="#{id}">)
    end

    # @param idref [String|Symbol] id of object we want to know is this object's ancestor
    # @return [Boolean] true if this object is descended from referenced object
    def descended_from?(idref)
      xml.ancestors.each do |ancestor|
        return true if ancestor.name == idref.to_s
        return true if ancestor.type == idref.to_s
      end
      false
    end

    # @return [Fixnum] index position of this object among its siblings
    def position
      parent.children.each_with_index do |child, index|
        return index if child == self
      end
    end
  end # module ObjectInterface
end # module Duxml
