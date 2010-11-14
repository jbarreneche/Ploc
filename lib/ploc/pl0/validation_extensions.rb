require 'ploc/pl0/syntax'
require 'ploc/token'

module Ploc::PL0
  module ValidationExtensions
    Syntax.nodes[:assign].extend_to ::Ploc::Token::Operand, ::Ploc::Token::Operand::EQUAL
    Syntax.nodes[:multiple_sentences].separator_is_weak!
    Syntax.nodes[:bop].extend_to ::Ploc::Token::Operand
    Syntax.nodes[:_do].extend_to ::Ploc::Token::ReservedWord
    Syntax.nodes[:declare_variables].on_error_flush_until_separator!
    Syntax.nodes[:declare_variables].separator_is_weak!
    Syntax.nodes[:assignment].on_error_flush_until_terminator!
  end
end
