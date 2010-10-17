require 'ploc/language'
require 'ploc/pl0/syntax'
require 'ploc/pl0/scanner'

module Ploc::PL0
  Language = Ploc::Language.new({
    parser:  Syntax,
    scanner_builder: ->(input) { Scanner.new(input) },
    compiler_builder: -> { Compiler.new },
  })
  def Language.to_s; "Ploc::PL0::Language"; end
end