require 'spec_helper'
require 'ploc/address'

describe Ploc::Address do
  subject { Ploc::Address.new(23) }
  it 'has a value' do
    subject.value.should == 23 
  end
  it 'calculates distance between other address' do
    other_address = Ploc::Address.new(50)
    new_address = subject - other_address
    new_address.value.should == (23 - 50)
  end
  it 'can be incremented by an amount' do
    new_address = subject + 10
    new_address.should be_a(Ploc::Address)
    new_address.value.should == (23 + 10)
  end
end