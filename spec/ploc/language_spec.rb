require 'spec_helper'
require 'ploc/language'

describe Ploc::Language do
  let(:scanner) { mock("Scanner")}
  let(:parser) { mock("Parser")}
  let(:compiler) { mock("Compiler", :errors => (@compiler_errors || []))}

  it { should respond_to(:compile) }

  it 'should have a parser' do
    subject.should respond_to(:parser, :parser=)
  end
  it 'should know how to create a fresh new scanner' do
    subject.should respond_to(:scanner_builder, :scanner_builder=)
  end
  it 'should know how to create a fresh new compiler' do
    subject.should respond_to(:compiler_builder, :compiler_builder=)
  end
  it 'should delegate parsing to parser using a dummy compiler with the a new scanner' do
    Ploc::DummyCompiler.should_receive(:new).with(scanner) { compiler }
    parser.should_receive(:parse).with(:program, compiler)

    subject.stub_chain(:scanner_builder, :call) { scanner }
    subject.should_receive(:parser) { parser }

    subject.parse("program").should == []
  end
end