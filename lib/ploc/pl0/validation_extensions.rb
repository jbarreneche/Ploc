require 'ploc/pl0/syntax'
require 'ploc/token'

module Ploc::PL0
  module ValidationExtensions
    Syntax.nodes[:assign].extend_to ::Ploc::Token::Operand, ::Ploc::Token::Operand::EQUAL
    Syntax.nodes[:multiple_sentences].separator_is_weak!
  end
end
