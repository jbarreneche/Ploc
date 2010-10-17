require 'ploc/token/unknown'

module Ploc::Token
  class String < Base
    def self.build(string)
      if string[0] == string[-1]
        new(string[1..-2])
      else
        Unknown.new(string)
      end
    end
  end
end