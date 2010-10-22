require 'spec_helper'
require 'ploc/binary_data'
require 'stringio'

describe Ploc::BinaryData do
  it 'should stream correctly one simply pair' do
    stream = StringIO.new
    stream << Ploc::BinaryData.new("#{?a.ord.to_s(16)}") # ?a.ord => 97
    stream.string.should == "a"
  end
  it 'should stream correctly multiple pairs' do
    stream = StringIO.new
    stream << Ploc::BinaryData.new("#{?a.ord.to_s(16)} #{?b.ord.to_s(16)}") # ?a.ord => 97
    stream.string.should == "ab"
  end
  it 'should discard comments' do
    stream = StringIO.new
    stream << Ploc::BinaryData.new(<<-BIN_DATA)
      #{?a.ord.to_s(16)} #{?b.ord.to_s(16)} # This are the first 2 letters
      #{?c.ord.to_s(16)} #{?d.ord.to_s(16)} # This are the next 2 letters
    BIN_DATA
    stream.string.should == "abcd"
  end
  it 'should parse int into little? endian format' do
    Ploc::BinaryData.parse_int(3).to_s.should == "\x3\0\0\0"
  end
  it 'should parse negatives int into little? endian format' do
    Ploc::BinaryData.parse_int(-1).to_s.should == "\xff\xff\xff\xff"
  end
end