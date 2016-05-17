# Copyright (c) 2016 Freescale Semiconductor Inc.

class Fixnum
  NUM_NAMES = %w(zero one two three four five six seven eight nine ten eleven twelve thirteen fourteen fifteen sixteen seventeen eighteen nineteen twenty thirty forty fifty sixty seventy eighty ninety)
  ORDINAL_SUFFIXES = %w(th st nd rd th)
  ORDINAL_NAMES = %w(zeroth first second third fourth fifth sixth seventh eighth ninth tenth eleventh twelfth)

  # @return [String] short string ordinal e.g. 3.ordinal =? 'third'
  def ordinal
    self.to_s + suffix
  end

  def suffix
    if self%100 < 4 or self%100 > 20
      ORDINAL_SUFFIXES[self%10]
    else
      ORDINAL_SUFFIXES.first
    end
  end

  # @return [String] full name of number e.g. 200058.to_word => 'two-hundred thousand and fifty-eight' for any Fixnum less than a billion
  def to_word
    case
      when self < 21 then NUM_NAMES[self]
      when self < 100
        ones = self%10
        ones_str = ones.zero? ? '' : "-#{ones.to_word}"
        NUM_NAMES[self/10+18]+ones_str
      when self < 1000
        tens = self%100
        "#{NUM_NAMES[self/100]} hundred #{'and '+(tens).to_word unless tens.zero?}"
      when self < 1000000
        remainder = self%1000 < 100 ? "and #{(self%1000).to_word}" : (self%1000).to_word
        "#{(self/1000).to_word} thousand #{remainder}"
      when self < 1000000000
        "#{(self/1000000).to_word} million #{(self%1000000).to_word}"
      else raise Exception, 'method only supports names for numbers less than 1000000000 i.e. <= 999,999,999'
    end.strip.gsub(' and zero', '')
  end

  # @return [String] full name of ordinal number e.g. 4281.ordinal_name => 'four thousand and two-hundred eighty-first'
  def ordinal_name
    ones = self%10
    tens = self%100
    case
      when tens.zero? then self.to_word+ORDINAL_SUFFIXES.first
      when ones.zero? && tens > 10 then self.to_word[-3..-1] + 'tieth'
      when ones.zero? && tens == 10 then self.to_word+ORDINAL_SUFFIXES.first
      when tens < 13 then "#{(self-tens).to_word} and #{ORDINAL_NAMES[tens]}"
      when tens < 20 && tens > 12
        "#{(self-tens).to_word} and #{NUM_NAMES[tens]}#{ORDINAL_SUFFIXES.first}"
      when tens-ones != 0 then "#{(self-ones).to_word}-#{ORDINAL_NAMES[ones]}"
      else "#{(self-ones).to_word} and #{ORDINAL_NAMES[ones]}"
    end.strip.gsub('zero and ', '').gsub('zero', '')
  end
end