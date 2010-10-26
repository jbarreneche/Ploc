require 'spec_helper'
require 'ploc/token'

describe Ploc::Token do
  describe '.tokenize' do
    it 'recognizes string words as identifiers' do
      Ploc::Token.tokenize('bla').should be_a(Ploc::Token::Identifier)
    end
    it 'recognizes numbers as token numbers' do
      Ploc::Token.tokenize('123').should be_a(Ploc::Token::Number)
    end
    it 'recognizes certain symbols as operands' do
      Ploc::Token::Operand::ALL.each do |operand|
        Ploc::Token.tokenize(operand).should be_a(Ploc::Token::Operand)
      end
    end
    it 'recognizes reserved words' do
      Ploc::Token::ReservedWord::ALL.each do |operand|
        Ploc::Token.tokenize(operand).should be_a(Ploc::Token::ReservedWord)
      end
    end
    it 'recognize strange symbols as Unknown token' do
      Ploc::Token.tokenize('$').should be_a(Ploc::Token::Unknown)
    end
    it 'recognizes strings delimited by double quotes as strings' do
      Ploc::Token.tokenize(%Q{"$"}).should be_a(Ploc::Token::String)
    end
    it 'recognizes strings delimited by single quotes as strings' do
      Ploc::Token.tokenize(%Q{'$'}).should be_a(Ploc::Token::String)
    end
    it 'recognizes open strings as Unkown token' do
      Ploc::Token.tokenize(%Q{"$ \n \n }).should be_a(Ploc::Token::Unknown)
    end
  end
  describe 'equality' do
    it 'compares case insensitively with tokens of the same type' do
      Ploc::Token.tokenize('bla').should == Ploc::Token.tokenize('BLA')
    end
    it 'compares case insensitively with strings' do
      Ploc::Token.tokenize('bla').should == 'BLA'
    end
  end
end