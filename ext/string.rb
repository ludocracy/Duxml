require_relative 'regexp'

class String
  def identifier?
    self.match(Regexp.identifier).to_s == self
  end

  def classify
    split('_').collect do |word| word.capitalize unless word == '_' end.join
  end
end