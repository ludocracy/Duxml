# Copyright (c) 2016 Freescale Semiconductor Inc.
require File.expand_path(File.dirname(__FILE__) + '/regexp')

class String
  # @return [String] converts string into Ruby constant. self must be String with no whitespaces and match Regexp.nmtoken
  #   'foo-bar'.constantize => 'Foo_bar'
  #   'foo_bar'.constantize => 'FooBar'
  #   'fooBar'.constantize  => 'FooBar'
  def constantize
    return self if Regexp.constant.match(self)
    raise Exception unless Regexp.nmtoken.match(self)
    s = split('_').collect do |word| word[0] = word[0].upcase; word unless word == '_' end.join.gsub('-', '_')
    raise Exception unless s.match(Regexp.constant)
    s
  end

  # @param sym [Symbol] optional setting for what type of nmtoken desired: either :snakeCase or :under_score
  # @return [String] does reverse of #constantize e.g.
  #   'Foo_b'.nmtokenize  => 'foo-bar'
  #   'FooBar'.nmtokenize => 'foo_bar'
  def nmtokenize(sym = :under_score)
    split('::').collect do |word|
      s = word.gsub(/(?!^)[A-Z_]/) do |match|
        case
          when match == '_' then '-'
          when sym == :snakeCase
            match
          when sym == :under_score
            "_#{match.downcase}"
          else
        end
      end
      s[0] = s[0].downcase
      s
    end.join(':')
  end
end # class String
