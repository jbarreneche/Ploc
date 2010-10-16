require 'ploc/language'
require 'ploc/pl0/syntax'

module Ploc::PL0
  Language = Ploc::Language.new
  Language.parser = Syntax
  Language.scanner_builder = Proc.new {|input| Ploc::Scanner.new(input) }
  Language.compiler_builder = Proc.new { Compiler.new }
end