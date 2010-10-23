require 'spec_helper'
require 'ploc/address'

describe Ploc::Address do
  subject { Ploc::Address.new(23) }
  its('value') { should == 23 }
  it 'should allow to become binary' do
    subject.to_bin.should == "\x17\x00\x00\x00"
  end
  it 'should calculate distance between other address' do
    other_address = Ploc::Address.new(50)
    new_address = subject - other_address
    new_address.value.should == (23 - 50)
  end
end