require 'spec_helper'
require 'ploc/language_node'

module Ploc::LanguageNode
  describe Terminal do
    let(:language) { stub('Language') }
    let(:errors) { stub('Errors').as_null_object }
    subject { Terminal.new(language, Fixnum, "1")}
    describe 'Transversing' do
      it 'advances source_code token' do
        source_code = mock('SourceCode', current_token: 1)
        source_code.should_receive(:next_token)
        subject.call source_code
      end
    end
    describe 'language extensions' do
      before(:each) do
        subject.extend_to Fixnum, "2"
      end
      it 'skips token if current matches the extension' do
        source_code = mock('SourceCode', current_token: 2, errors: errors).as_null_object
        source_code.should_receive(:next_token)
        subject.call source_code
      end
      it 'reports the error to source_code' do
        source_code = mock('SourceCode', current_token: 2, next_token: 3, errors: errors)
        source_code.should_receive(:report_error)
        subject.call source_code
      end
      it 'doesnt skip token if current doesnt match any extension' do
        source_code = mock('SourceCode', current_token: 3, errors: errors).as_null_object
        source_code.should_not_receive(:next_token)
        subject.call source_code
      end
    end
  end
end