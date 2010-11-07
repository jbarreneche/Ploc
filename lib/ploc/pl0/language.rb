require 'ploc/language'

require 'ploc/pl0/scanner'
require 'ploc/pl0/semantic_rules'
require 'ploc/pl0/validation_extensions'
require 'ploc/pl0/compiling_context'

module Ploc::PL0
  Language = Ploc::Language.new({
    parser:  Syntax,
    scanner_builder: ->(input) { Scanner.new(input) },
    context_builder: ->(source_code, output) { CompilingContext.new(source_code, output) }
  })
  def Language.to_s; "Ploc::PL0::Language"; end
end