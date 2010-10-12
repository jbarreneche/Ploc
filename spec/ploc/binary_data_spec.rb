require 'spec_helper'
require 'ploc/binary_data'
require 'stringio'

describe Ploc::BinaryData do
  it 'should stream correctly one simply pair' do
    stream = StringIO.new
    stream << Ploc::BinaryData.new("#{?a.ord}") # ?a.ord => 97
    stream.string.should == "a"
  end
  it 'should stream correctly multiple pairs' do
    stream = StringIO.new
    stream << Ploc::BinaryData.new("#{?a.ord} #{?b.ord}") # ?a.ord => 97
    stream.string.should == "ab"
  end
  it 'should discard comments' do
    stream = StringIO.new
    stream << Ploc::BinaryData.new(<<-BIN_DATA)
      #{?a.ord} #{?b.ord} # This are the first 2 letters
      #{?c.ord} #{?d.ord} # This are the next 2 letters
    BIN_DATA
    stream.string.should == "abcd"
  end
end