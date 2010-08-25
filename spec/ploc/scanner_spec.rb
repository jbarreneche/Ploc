require 'spec_helper'
require 'ploc/scanner'
require 'stringio'

describe Ploc::Scanner do
  it 'should tokenize empty program' do
    scanner = Ploc::Scanner.new(StringIO.new("."))
    array = scanner.to_a
    array.should have(1).token
    array.map(&:to_s).first.should == '.'
  end
  it 'should tokenize text and symbols' do
    scanner = Ploc::Scanner.new(StringIO.new("symbol := 23a;\nl3tt3randnumb3r:=3*(symbol + symbol)"))
    scanner.to_a.map(&:to_s).should == %w[symbol := 23 a ; l3tt3randnumb3r := 3 * ( symbol + symbol )]
  end
  it 'should tokenize iteratibely' do
    input = mock('input')
    input.should_receive(:gets).and_return('something blue')
    input.should_receive(:eof?).exactly(2).times.and_return(false)
    scanner = Ploc::Scanner.new(input)
    scanner.next.should == 'something'
    scanner.next.should == 'blue'
    input.should_receive(:gets).and_return('anything black')
    scanner.next.should == 'anything'
    scanner.next.should == 'black'
  end
end