require 'spec_helper'
require 'ploc/language'

describe Ploc::Language do
  let(:scanner) { mock("Scanner")}
  let(:parser) { mock("Parser")}
  let(:source_code) { mock("SourceCode") }
  let(:context) { stub("Context", source_code: source_code, errors: (@errors || [])).as_null_object }

  it { should respond_to(:compile) }

  it 'should have a parser' do
    subject.should respond_to(:parser, :parser=)
  end
  it 'should know how to create a fresh new scanner' do
    subject.should respond_to(:scanner_builder, :scanner_builder=)
  end
  it 'should know how to create a fresh new compiler' do
    subject.should respond_to(:context_builder, :context_builder=)
  end
  it 'should delegate parsing to parser using a new validation contextdummy compiler with the a new scanner' do
    parser.should_receive(:parse).with(:program, context.source_code) { }

    subject.stub_chain(:scanner_builder, :call) { scanner }
    subject.stub_chain(:context_builder, :call) { context }
    subject.should_receive(:parser) { parser }

    Ploc::SourceCode.should_receive(:new).with(scanner) { source_code }
    Ploc::ValidationContext.should_receive(:new).with(source_code) { context }
    subject.parse("program").should == []
  end
end