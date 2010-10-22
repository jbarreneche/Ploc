require 'spec_helper'
require 'ploc/source_code'

describe Ploc::SourceCode do
  let(:scanner) { mock 'Scanner' }
  subject { Ploc::SourceCode.new(scanner) }
  its(:current_token) { should be_nil }
  its(:errors) { should be_empty }
  it 'should delegate token to scanner' do
    scanner.should_receive(:next) { :token }
    subject.next_token.should == :token
  end
end