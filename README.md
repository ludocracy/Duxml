Copyright (c) 2016 Freescale Semiconductor Inc.

# Duxml for Ruby
Duxml binds XML to Ruby objects and classes and vice versa, allowing validation of structure and content using Ruby statements, implemented as a wrapper for Ox XML parser.
Its goal is to allow Ruby users to automate the generation of XML documents without having to know their exact schema rules, 
and it allows XML users without any knowledge of Ruby to manipulate dataflows through the use of namespaced elements bound to Ruby methods.

## Features:
- Ox gem based
- Lazy-duck XML creation (even lazier than Ox's): you can use a file path, a string, or any Ruby object at all.
- Static and runtime validation using flattened DTD: 
    - notifies you that an XML edit action violates a DTD rule
    - allows edit to take place so process is not interrupted
- flattened DTD to RelaxNG conversion: 'flattened' as in all type group nestings are dissolved; output can be used by Ox to validate static XML.
- XML content validation using Regexp
- Automated change-logging 
- Duck-caller i.e. dynamic, JIT extending XML elements with corresponding named module's methods. 

## Duck-calling
Uses Ox::Element's #method_missing to:
1. map element's name to a Module
2. extend Ox::Element with Module's methods 
3. call method again
e.g.
     
     require 'duxml'
     
     module Maudule
       def foo
         'bar' 
       end
     end
       
     x = xml '<maudule/>'  => [XML::Element]
     x.respond_to?
     x.foo                 => 'bar'

## Roadmap:
- Runtime validation using RelaxNG
- Content validation using secured Ruby code blocks
- Automated documentation generation template
- Automated check-in comment template

## Metadata
Any file parsed by Duxml has a corresponding hidden metadata file containing its validation errors, change history, grammar, owner, etc.

### Grammar
The grammar can be defined in a DTD-style format by defining objects of the following classes:
 #NOTE: first Rule becomes root rule and therefore must be ChildrenRule!
    - ChildrenRule:     DTD/Regexp statement of allowed element children or text(i.e. 'PCDATA' or 'text')
    - TextRule:         Ruby expression (currently limited to Regexp!) that must match (all or part of) element's string content
    - AttrsRule:        DTD/Regexp statement of attributes allowed by element
    - ValueRule:        DTD/Regexp statement of allowed values of an attribute 
Structure enforcement can be done by invoking one of two methods:
    Grammar#qualify     is invoked indirectly by user any time they change the loaded XML document
    Duxml#validate      when called directly by user, runs Grammar#validate on every node of the loaded XML document
    Grammar#validate    can be called to inspect just one node

### History
The file history can become operational in two modes: strict and non-strict. You can set this by passing History#strict? a Boolean.
    - strict:       QualifyErrors will raise Exception
    - non-strict:   QualifyErrors do not raise Exception
    In BOTH cases, both the non-compliant change and the QualifyError 
    continue their normal processing, meaning if the user were to save 
    the file right then, the non-compliant change will remain and the 
    history will still show a QualifyError.
Changes and errors are logged together. First event is latest. Errors will point to changes, and changes should point to at least one node in the target file.
Types of changes: 
    - QualifyError: Grammar#qualify caught grammar violation
    - ValidateError: Grammar#validate found grammar violation 
    - Add: element added to element at a given index
    - NewText: string added to element at a given index
    - Remove: element removed from element
    - NewAttr: new attribute added to element with given value
    - ChangeAttr: existing attribute changed from old value to new value
    - ChangeText: existing string node of element changed to new string
