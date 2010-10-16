require 'ploc/syntax'
require 'ploc/token'

module Ploc::PL0
  Syntax = Ploc::Syntax.build do
    define :program do
      block; dot
    end
    define :block do
      const :zero_or_one do
        sequence(separator: :comma, terminator: :semicolon) {identifier; equal; number}
      end
      var :zero_or_one do
        sequence(separator: :comma, terminator: :semicolon) {identifier}
      end
      optional { sequence(repeat: true) { procedure; identifier; semicolon; block; semicolon }}
      sentence
    end
    define :sentence do
      optional do
        branch do
          sequence { identifier; assign; expression}
          sequence { _call; identifier }
          _begin do
            sequence(separator: :semicolon, terminator: :_end) {sentence}
          end
          sequence {_if; condition; _then; sentence}
          sequence {_while; condition; _do; sentence}
          sequence do 
            output; left_par
            sequence(separator: :comma) { output_expression }
            right_par
          end
          sequence { readln; left_par; identifier; right_par }
        end
      end
    end
    define :output do
      branch { write; writeln }
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
      optional { sign }
      sequence(separator: :sign) {term}
    end
    define :term do
      sequence(separator: :ration) {factor}
    end
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
end