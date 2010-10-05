require 'spec_helper'
require 'ploc/token'

describe Ploc::Token do
  it 'should recognize identifiers' do
    Ploc::Token.tokenize('bla').should be_a(Ploc::Token::Identifier)
  end
  it 'should recognize integers' do
    Ploc::Token.tokenize('123').should be_a(Ploc::Token::Number)
  end
  it 'should recognize operands' do
    Ploc::Token::Operand::ALL.each do |operand|
      Ploc::Token.tokenize(operand).should be_a(Ploc::Token::Operand)
    end
  end
  it 'should recognize reserved words' do
    Ploc::Token::ReservedWord::ALL.each do |operand|
      Ploc::Token.tokenize(operand).should be_a(Ploc::Token::ReservedWord)
    end
  end
  it 'shouldn\'t recognize strange symbols' do
    Ploc::Token.tokenize('$').should be_a(Ploc::Token::Unknown)
  end
  it 'should recognize strings' do
    Ploc::Token.tokenize('"$"').should be_a(Ploc::Token::String)
  end
  it 'shouldn\'t recognize open strings' do
    Ploc::Token.tokenize("\"$\n\n").should be_a(Ploc::Token::Unknown)
  end
end