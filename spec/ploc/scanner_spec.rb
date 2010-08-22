require 'spec_helper'
require 'ploc/scanner'
require 'stringio'

describe Ploc::Scanner do
  before(:each) do
    @scanner = Ploc::Scanner.new
  end
  it 'should tokenize empty program' do
    tokens = @scanner.scan(StringIO.new("."))
    array = tokens.to_a
    array.should have(1).token
    array.map(&:to_s).first.should == '.'
  end
  it 'should tokenize text and symbols' do
    tokens = @scanner.scan(StringIO.new("symbol := 23;\nletter:=3*(symbol + symbol)"))
    tokens.to_a.should == %w[symbol := 23 ; letter := 3 * ( symbol + symbol )]
  end
  it 'should tokenize iteratibely' do
    input = mock('input')
    input.should_receive(:gets).and_return('something blue')
    input.should_receive(:eof?).exactly(2).times.and_return(false)
    tokens = @scanner.scan(input)
    tokens.next.should == 'something'
    tokens.next.should == 'blue'
    input.should_receive(:gets).and_return('anything black')
    tokens.next.should == 'anything'
    tokens.next.should == 'black'
  end
end