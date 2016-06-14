# Copyright (c) 2016 Freescale Semiconductor Inc.
require File.expand_path(File.dirname(__FILE__) + '/regexp')

class String
  # @return [String] converts string into Ruby constant. self must be String with no whitespaces and match Regexp.nmtoken
  #   'foo-bar'.constantize => 'Foo_bar'
  #   'foo_bar'.constantize => 'FooBar'
  def constantize
    return self if Regexp.constant.match(self)
    raise Exception unless Regexp.nmtoken.match(self)
    s = split('_').collect do |word| word.capitalize unless word == '_' end.join.gsub('-', '_')
    raise Exception unless s.match(Regexp.constant)
    s
  end

  # @return [String] does reverse of #constantize e.g.
  #   'Foo_b'.nmtokenize  => 'foo-bar'
  #   'FooBar'.nmtokenize => 'foo_bar'
  def nmtokenize
    split('::').collect do |word|
      word.gsub(/(?!^)[A-Z_]/) do |match|
        case match
          when '_' then '-'
          else "_#{match.downcase}"
        end
      end.downcase
    end.join(':')
  end
end # class String
