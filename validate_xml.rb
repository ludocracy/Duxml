#!/usr/bin/env ruby
require_relative 'lib/dux'
require 'optparse'

include Dux

DITA_GRAMMAR_FILE = 'xml/Dita 1.3 Manual Spec Conversion.xlsx'
xml_file = ARGV.first
log_file = ARGV[1] || 'log.txt'

load xml_file
puts "loaded XML file: #{xml_file}"
current_meta.grammar = DITA_GRAMMAR_FILE
puts "loaded grammar file: #{DITA_GRAMMAR_FILE}"
validate
puts "validation complete"
log log_file
puts "logged errors to #{log_file}"