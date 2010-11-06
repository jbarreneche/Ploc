require 'ploc/scanner'

module Ploc::PL0
  class Scanner < Ploc::Scanner
    string_regex = ->(sep) {"#{sep}[^#{sep}]*#{sep}|#{sep}[^#{sep}]*$"}
    REGEX = /#{string_regex["'"]}|#{string_regex['"']}|\d+|\w+|:=|<=|<>|>=|\S/
    def initialize(input)
      super(input, REGEX)
    end
  end
end