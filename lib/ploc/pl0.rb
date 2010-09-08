require 'ploc/language_builder'
module Ploc
  PL0 = LanguageBuilder.new do
    define :program do
      sequence block, dot
    end
    define :block do
      const :zero_or_one do
        sequence identifier, equal, number, :separator => comma
      end
      var :zero_or_one do
        sequence identifier, :separator => comma
      end
      procedure :zero_or_more do
        sequence identifier, semicolon, block, :terminator => semicolon
      end
      sentence
    end
    define :sentence do
      branch :optional do
        sequence identifier, assign, expression
        sequence call, identifier
        _begin do
          sequence proposition, :separator => semicolon, :terminator => _end
        end
        sequence _if, condition, _then, proposition
        sequence _while, condition, _do, proposition
      end
    end
    define :condition do
      branch do
        sequence odd, expression
        sequence expression, bop, expression
      end
    end
    define :expression do
      optional sign
      sequence term, :separator => sign
    end
    define :term do
      sequence factor, :separator => ration
    end
    define :factor do
      branch do
        identifier
        number
        sequence left_par, expression, right_par
      end
    end
    Token::ReservedWord::ALL.each do |word|
      term Token::ReservedWord.santize(word).to_sym, Token::ReservedWord, word
    end
    term :assign, Token::Operand, Token::Operand::SIGN
    term :bop, Token::Operand, *Token::Operand::BOPS
    term :ration, Token::Operand, *Token::Operand::RATIONS
    term :sign, Token::Operand, *Token::Operand::SIGNS
    term :left_par, Token::Operand, Token::Operand::LEFT_PAR
    term :right_par, Token::Operand, Token::Operand::RIGHT_PAR
    term :identifier, Token::Identifier
    term :number, Token::Number
  end
end