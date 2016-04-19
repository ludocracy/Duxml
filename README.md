# Duxml for Ruby
Duxml binds XML to Ruby objects and classes and vice versa, allowing validation of structure and content using Ruby statements, implemented as a wrapper for Ox XML parser.
Its goal is to allow Ruby users to automate the generation of XML documents without having to know their exact schema rules, 
and it allows XML users without any knowledge of Ruby to manipulate dataflows through the use of namespaced elements bound to Ruby methods.

## Features:
- The whole Ox
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