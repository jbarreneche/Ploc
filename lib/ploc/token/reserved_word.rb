module Ploc::Token
  class ReservedWord < Base
    ALL = %w[const var procedure begin end if while call then do odd readln write writeln]
    RUBY_RESERVED_WORDS = %w[begin end if while call then do]
    def self.sanitize(string)
      return "_#{string}" if RUBY_RESERVED_WORDS.include? string
      string
    end
  end
end