require 'spec_helper'
require 'ploc/language'

describe Ploc::Language do
  it { should respond_to(:compile) }
  it 'should have a parser' do
    subject.should respond_to(:parser)
    subject.should respond_to(:parser=)
  end
  it 'should know how to create a fresh new scanner' do
    subject.should respond_to(:scanner_builder)
    subject.should respond_to(:scanner_builder=)
  end
  it 'should know how to create a fresh new compiler' do
    subject.should respond_to(:compiler_builder)
    subject.should respond_to(:compiler_builder=)
  end
  it 'should delegate parsing to parser using the a new scanner' do
    scanner = mock("Scanner")
    parser = mock("Parser")
    compiler = mock("Compiler", :errors => [])
    Ploc::DummyCompiler.should_receive(:new).with(scanner) { compiler }
    subject.stub_chain(:scanner_builder, :call) { scanner }
    subject.should_receive(:parser) { parser }
    parser.should_receive(:parse).with(:program, compiler)
    subject.parse("program").should == []
  end
end