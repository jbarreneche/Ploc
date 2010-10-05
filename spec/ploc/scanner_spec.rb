require 'spec_helper'
require 'ploc/scanner'
require 'stringio'

describe Ploc::Scanner do
  it 'should tokenize empty program' do
    scanner = Ploc::Scanner.new(StringIO.new("."))
    array = scanner.to_a
    array.pop.should be_nil
    array.should have(1).token
    array.first.to_s.should == '.'
  end
  it 'should tokenize text and symbols' do
    scanner = Ploc::Scanner.new(StringIO.new("    symbol := 23a;   \n\t  \t l3tt3randnumb3r:=3*(symbol + symbol)     "))
    array = scanner.to_a
    array.pop.should be_nil
    array.map(&:to_s).should == %w[symbol := 23 a ; l3tt3randnumb3r := 3 * ( symbol + symbol )]
  end
  it 'should tokenize iteratibely' do
    input = mock('input')
    input.should_receive(:gets).and_return('something blue')
    input.should_receive(:eof?).exactly(2).times.and_return(false)
    scanner = Ploc::Scanner.new(input)
    scanner.next.to_s.should == 'something'
    scanner.next.to_s.should == 'blue'
    input.should_receive(:gets).and_return('anything black')
    scanner.next.to_s.should == 'anything'
    scanner.next.to_s.should == 'black'
  end
  it 'should keep track of current line' do
    input = mock('input')
    input.should_receive(:gets).and_return('something blue')
    input.should_receive(:gets).and_return('anything black')
    input.stub(:eof?).and_return(false)
    scanner = Ploc::Scanner.new(input)
    scanner.next
    scanner.current_line.should == 'something blue'
    scanner.line_number == 1
    scanner.next
    scanner.current_line.should == 'something blue'
    scanner.line_number == 1

    scanner.next
    scanner.current_line.should == 'anything black'
    scanner.line_number == 2
  end
end