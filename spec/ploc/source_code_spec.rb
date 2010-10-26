require 'spec_helper'
require 'ploc/source_code'

describe Ploc::SourceCode do
  subject { Ploc::SourceCode.new(scanner) }
  let(:scanner) { mock 'Scanner' }

  its(:current_token) { should be_nil }
  its(:errors) { should be_empty }

  it 'delegates next_token to scanner' do
    scanner.should_receive(:next) { :token }
    subject.next_token.should == :token
  end
end