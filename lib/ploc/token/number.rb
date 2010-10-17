require 'ploc/token/unknown'

module Ploc::Token
  class Number < Base
    MAX_INT = (2 ** 31)
    def self.build(token)
      integer = token.to_i
      if integer < MAX_INT
        new(integer)
      else
        Unknown.build(token)
      end
    end
  end
end