require 'ploc/syntax'
require 'ploc/token'
module Ploc
  PL0_SYNTAX = Syntax.build do
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
    Token::ReservedWord::ALL.each do |word|
      terminal Token::ReservedWord.sanitize(word).to_sym, Token::ReservedWord, word
    end
    terminal :string, Token::String
    terminal :assign, Token::Operand, Token::Operand::ASSIGN
    terminal :bop, Token::Operand, *Token::Operand::BOPS
    terminal :equal, Token::Operand, Token::Operand::EQUAL
    terminal :comma, Token::Operand, Token::Operand::COMMA_SEPARATOR
    terminal :dot, Token::Operand, Token::Operand::DOT
    terminal :identifier, Token::Identifier
    terminal :left_par, Token::Operand, Token::Operand::LEFT_PAR
    terminal :number, Token::Number
    terminal :ration, Token::Operand, *Token::Operand::RATIONS
    terminal :right_par, Token::Operand, Token::Operand::RIGHT_PAR
    terminal :semicolon, Token::Operand, Token::Operand::SEMICOLON_SEPARATOR
    terminal :sign, Token::Operand, *Token::Operand::SIGNS
  end
end