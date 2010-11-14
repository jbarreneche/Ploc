require 'spec_helper'
require 'ploc/scope'

describe Ploc::Scope do
  let(:context) { double('Context') }
  subject { Ploc::Scope.new(context) }
  
  it { should have(0).constants }
  it { should have(0).variables }
  it { should have(0).procedures }
  it { subject.parent.should be_nil }
  before(:each) do
    context.stub(:build_variable) {|v| v }
    context.stub(:build_constant) {|c| c }
    context.stub(:build_procedure) {|p| p }
  end
  context 'declaring variables' do
    it 'should allow to declare variables' do
      foo_var = subject.declare(:variable, :foo)
      subject.should have(1).variables
      subject.variables.should include(foo_var)
    end
    it 'should build variables from context' do
      foo_var = mock('FooVar')
      context.should_receive(:build_variable).with(:foo).and_return(foo_var)
      subject.declare(:variable, :foo).should == foo_var
    end
    it 'should\'nt allow to declare already declared variables' do
      foo_var = subject.declare(:variable, :foo)
      expect {
        subject.declare(:variable, :foo)
      }.to raise_error(Ploc::DuplicateDeclarationError)
    end
    it 'should allow to retrieve declared variables' do
      foo_var = subject.declare(:variable, :foo)
      subject.retrieve_variable(:foo).should == foo_var
    end
  end
  context 'declaring constants' do
    it 'should allow to declare variables' do
      foo_cons = subject.declare(:constant, :foo)
      subject.should have(1).constants
      subject.constants.should include(foo_cons)
    end
    it 'should build constants from context' do
      foo_cons = mock('FooCons')
      context.should_receive(:build_constant).with(:foo).and_return(foo_cons)
      subject.declare(:constant, :foo).should == foo_cons
    end
    it 'should\'nt allow to declare already declared variables' do
      foo_cons = subject.declare(:constant, :foo)
      expect {
        subject.declare(:constant, :foo)
      }.to raise_error(Ploc::DuplicateDeclarationError)
    end
  end
  context 'declaring procedures' do
    it 'should allow to declare procedures' do
      foo_proc = subject.declare(:procedure, :foo)
      subject.should have(1).procedures
      subject.procedures.should include(foo_proc)
    end
    it 'should build procedures from context' do
      foo_proc = mock('FooProc')
      context.should_receive(:build_procedure).with(:foo).and_return(foo_proc)
      subject.declare(:procedures, :foo).should == foo_proc
    end
    it 'should\'nt allow to declare already declared procedures' do
      foo_proc = subject.declare(:procedure, :foo)
      expect {
        subject.declare(:procedure, :foo)
      }.to raise_error(Ploc::DuplicateDeclarationError)
    end
  end
  context 'nesting scopes' do
    before(:each) do
      @parent = subject
      @subcontext = @parent.build_subcontext
    end
    it 'should allow to create subcontexts' do
      @subcontext.parent.should == @parent
    end
    it 'subcontext should have parents declarations' do
      foo_bar = @parent.declare(:variable, :foo)
      @subcontext.variables.should include(foo_bar)
    end
    it 'subcontext should allow shadowing declarations' do
      foo_bar = @parent.declare(:variable, :foo)
      foo_bar_shadow = @subcontext.declare(:variable, :foo)
      @subcontext.variables.should include(foo_bar)
    end
  end
  context 'retrieving from local' do
    it 'allows to retrieve declared type' do
      foo_var = subject.declare(:variable, :foo)
      subject.retrieve_variable(:foo) == foo_var
    end
    it 'allows to retrieve declared type in parent' do
      foo_var = subject.declare(:variable, :foo)
      subcontext = subject.build_subcontext
      subcontext.retrieve_variable(:foo) == foo_var
    end
    it 'raises UndeclaredIdentifierError when not declared' do
      foo_var = subject.declare(:variable, :bar)
      subcontext = subject.build_subcontext
      expect {
        subcontext.retrieve_constant(:foo)
      }.to raise_error(Ploc::UndeclaredIdentifierError)
    end
    it 'raises WrongTypeDeclarationError when the declared type doesnt match the fetch type' do
      foo_var = subject.declare(:variable, :foo)
      subcontext = subject.build_subcontext
      expect {
        subcontext.retrieve_constant(:foo)
      }.to raise_error(Ploc::WrongTypeDeclarationError)
    end
  end
end