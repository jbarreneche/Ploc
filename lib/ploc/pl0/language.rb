require 'ploc/language'
require 'ploc/pl0/syntax'
require 'ploc/pl0/scanner'
require 'ploc/pl0/compiling_context'

module Ploc::PL0
  Language = Ploc::Language.new({
    parser:  Syntax,
    scanner_builder: ->(input) { Scanner.new(input) },
    context_builder: ->(source_code) { CompilingContext.new(source_code) },
  })
  def Language.to_s; "Ploc::PL0::Language"; end
end