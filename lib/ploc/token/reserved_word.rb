module Ploc::Token
  class ReservedWord < Base
    ALL = %w[const var procedure begin end if while]
    RUBY_RESERVED_WORDS = %w[begin end if while]
    def self.sanitize(string)
      return "_#{string}" if RUBY_RESERVED_WORDS.include? string
      string
    end
  end
end