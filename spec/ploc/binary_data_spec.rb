require 'spec_helper'
require 'ploc/binary_data'
require 'stringio'

describe Ploc::BinaryData do
  it 'streams correctly one simply pair' do
    stream = StringIO.new
    stream << Ploc::BinaryData.new("#{?a.ord.to_s(16)}") # ?a.ord => 97
    stream.string.should == "a"
  end
  it 'streams correctly multiple pairs' do
    stream = StringIO.new
    stream << Ploc::BinaryData.new("#{?a.ord.to_s(16)} #{?b.ord.to_s(16)}") # ?a.ord => 97
    stream.string.should == "ab"
  end
  it 'discards comments' do
    stream = StringIO.new
    stream << Ploc::BinaryData.new(<<-BIN_DATA)
      #{?a.ord.to_s(16)} #{?b.ord.to_s(16)} # This are the first 2 letters
      #{?c.ord.to_s(16)} #{?d.ord.to_s(16)} # This are the next 2 letters
    BIN_DATA
    stream.string.should == "abcd"
  end
  it 'parses an int into little endian format' do
    Ploc::BinaryData.new(3).to_s.should == "\x3\0\0\0"
  end
  it 'parses negatives int into little endian format' do
    Ploc::BinaryData.new(-1).to_s.should == "\xff\xff\xff\xff"
  end
  it 'parses multiple creation arguments' do
    Ploc::BinaryData.new("B8", -1).to_s.should == "\xB8\xff\xff\xff\xff"
  end
end