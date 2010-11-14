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
    Syntax.nodes[:multiple_sentences].on_fail_terminator_resync_to_separator!
    Syntax.nodes[:string].extend_to ::Ploc::Token::Unknown
    branch = Syntax.nodes[:output_expression].__send__(:sequence_nodes).first
    def branch.call_without_callbacks(source_code)
      super || begin
        source_code.next_token while source_code.current_token && source_code.current_token != ')' && source_code.current_token != 'end'
        source_code.current_token
      end
    end
  end
end
