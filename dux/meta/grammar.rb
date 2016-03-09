require File.expand_path(File.dirname(__FILE__) + '/../../dux/dux_object')

class Pattern < DuxObject
  def initialize subj, args = {}
    if subj.respond_to?(:is_component?)
      xml_node = class_to_xml args
      xml_node[:subject] = subj.id
    else
      xml_node = subj
    end
    super xml_node, args
  end

  def subject context_root=root
    resolve_ref :subject, context_root
  end

  def object
    has_children? ? children.first : resolve_ref(:object, root)
  end

  def <=> pattern
    return 1 unless pattern.respond_to?(:subject)
    case subject <=> pattern.subject
      when -1 then -1
      when 0 then object <=> pattern.object
      else -1
    end
  end

  def class_to_xml args={}
    xml_node = super()
    args.each do |k, v| xml_node[k] = v.respond_to?(:id) ? v.id : v end
    xml_node
  end

  private :class_to_xml
end # class Pattern

class Grammar < DuxObject
  def initialize xml_node, args={}
    super xml_node, reserved: %w{rule}
  end

  def validate comp
    relationships = {}
    comp.children.each do |child| relationships[child] = :child end
    comp.attributes.each do |k, v| relationships[v] = "attr_name_#{k.to_s}".to_sym end
    relationships[comp.content] = :content
    relationships[comp.parent] = :parent
    relationships.each do |rel, type| qualify Pattern.new(comp, {relationship: type, object: rel}) end
  end

  def qualify change
    children.each do |child|
      subj = change.subject meta
      if subj && child[:subject] == subj.type
        child.qualify change
      end
    end
  end
end # class Grammar

class Rule < Pattern
  def qualify change
    subject = change.subject meta
    object = change.object

    begin
      # TODO use a safer eval - filter? use limited eval?
      # one statement only
      # no objects but components or dux_object arguments
      # no methods but dux_object interface or sub interfaces
      qualified_or_false = eval content
    rescue NoMethodError
      qualified_or_false ||= true
    end

    if change.type == 'pattern'
      type = :validate_error
      target = subject
    else
      type = :qualify_error
      target = change
    end

    report type, target unless qualified_or_false
    qualified_or_false
  end

  def class_to_xml args={}
    xml_node = super
    xml_node[:subject] = args[:subject].to_s
    xml_node << args[:statement]
    xml_node.remove_attribute 'statement'
    xml_node
  end

  private :class_to_xml
end # class Rule