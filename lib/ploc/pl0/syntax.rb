require 'ploc/syntax'
require 'ploc/token'

module Ploc::PL0
  Syntax = Ploc::Syntax.build do
    define :program do
      block; dot
    end
    define :block do
      optional { const; declare_constants }
      optional { var; declare_variables }
      optional(repeat: true, name: :declare_procedure) do 
        procedure; identifier; semicolon
        procedure_block
        semicolon
      end
      sentence
    end
    # Alias block as procedure_block to control diferent semantics
    define(:procedure_block) { block }
    define :declare_constants, separator: :comma, terminator: :semicolon do
      identifier; equal; number
    end
    define :declare_variables, separator: :comma, terminator: :semicolon do
      identifier
    end
    define :sentence do
      optional do
        branch do
          sequence(name: :assignment) { identifier; assign; expression}
          sequence(name: :call_procedure) { _call; identifier }
          sequence { _begin; multiple_sentences; _end }
          sequence(name: :branch) {_if; condition; _then; sentence}
          sequence(name: :loop)  {_while; condition; _do; sentence}
          sequence { writeln; optional { output_params } }
          sequence { write; output_params }
          sequence { readln; left_par; identifier; right_par }
        end
      end
    end
    define(:multiple_sentences, separator: :semicolon) { sentence }
    define :output_params do
      left_par
      sequence(separator: :comma) { output_expression } 
      right_par
    end
    define :output_expression do
      branch { string; expression }
    end
    define :condition do
      branch do
        sequence {odd; expression}
        sequence {expression; bop; expression}
      end
    end
    define :expression do
      first_expresion;
      optional do
        sign;
        sequence(separator: :sign, name: :more_expressions) {term}
      end
    end

    define(:first_expresion) do
      optional { sign }; term
    end

    define(:term, separator: :ration) {factor}

    define :factor do
      branch do
        identifier
        number
        sequence {left_par; expression; right_par}
      end
    end
    ::Ploc::Token::ReservedWord::ALL.each do |word|
      terminal ::Ploc::Token::ReservedWord.sanitize(word).to_sym, ::Ploc::Token::ReservedWord, word
    end
    terminal :string, ::Ploc::Token::String
    terminal :assign, ::Ploc::Token::Operand, ::Ploc::Token::Operand::ASSIGN
    terminal :bop, ::Ploc::Token::Operand, *::Ploc::Token::Operand::BOPS
    terminal :equal, ::Ploc::Token::Operand, ::Ploc::Token::Operand::EQUAL
    terminal :comma, ::Ploc::Token::Operand, ::Ploc::Token::Operand::COMMA_SEPARATOR
    terminal :dot, ::Ploc::Token::Operand, ::Ploc::Token::Operand::DOT
    terminal :identifier, ::Ploc::Token::Identifier
    terminal :left_par, ::Ploc::Token::Operand, ::Ploc::Token::Operand::LEFT_PAR
    terminal :number, ::Ploc::Token::Number
    terminal :ration, ::Ploc::Token::Operand, *::Ploc::Token::Operand::RATIONS
    terminal :right_par, ::Ploc::Token::Operand, ::Ploc::Token::Operand::RIGHT_PAR
    terminal :semicolon, ::Ploc::Token::Operand, ::Ploc::Token::Operand::SEMICOLON_SEPARATOR
    terminal :sign, ::Ploc::Token::Operand, *::Ploc::Token::Operand::SIGNS
  end
  def Syntax.to_s; "Ploc::PL0::Syntax"; end
end