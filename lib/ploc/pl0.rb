require 'ploc/language'
module Ploc
  PL0 = Language.build do
    define :program do
      sequence { block; dot }
    end
    define :block do
      const :zero_or_one do
        sequence(separator: :comma) {identifier; equal; number}
      end
      var :zero_or_one do
        sequence(separator: :comma) {identifier}
      end
      optional { sequence(repeat: true) { procedure; identifier; semicolon; block; semicolon }}
      procedure :zero_or_more do
        sequence(terminator: :semicolon) {identifier; semicolon; block}
      end
      sentence
    end
    define :sentence do
      branch :optional do
        sequence { identifier; assign; expression}
        sequence { call; identifier}
        _begin do
          sequence(separator: :semicolon, terminator: :_end) {sentence}
        end
        sequence {_if; condition; _then; sentence}
        sequence {_while; condition; _do; sentence}
      end
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
      term Token::ReservedWord.santize(word).to_sym, Token::ReservedWord, word
    end
    term :assign, Token::Operand, Token::Operand::SIGNS
    term :bop, Token::Operand, *Token::Operand::BOPS
    term :ration, Token::Operand, *Token::Operand::RATIONS
    term :sign, Token::Operand, *Token::Operand::SIGNS
    term :left_par, Token::Operand, Token::Operand::LEFT_PAR
    term :right_par, Token::Operand, Token::Operand::RIGHT_PAR
    term :identifier, Token::Identifier
    term :number, Token::Number
  end
end