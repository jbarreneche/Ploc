require 'spec_helper'
require 'ploc/semantic_context'

describe Ploc::SemanticContext do
  it { should have(0).constants }
  it { should have(0).variables }
  it { should have(0).procedures }
  its("scope") { should == subject }
  describe 'Building variables' do
    it 'should allow to declare new variables' do
      var_foo = subject.declare(:variable, :foo)
      subject.variables.should include(var_foo)
    end
    it 'should keep track of variable declaration' do
      var_foo = mock('Variable')
      subject.should_receive(:next_var_sequence) { 23 }
      Ploc::Variable.should_receive(:new).with(:foo, 23).and_return(var_foo)
      
      subject.declare(:variable, :foo).should == var_foo
    end
    it 'should increment var sequence' do
      n = subject.send :next_var_sequence
      n.should == 0
      v = rand(100) + 1
      v.times { n = subject.send :next_var_sequence }
      n.should == v
    end
  end
  describe 'Building constants' do
    it 'should allow to declare new constants' do
      const_foo = subject.declare(:constant, :foo, 100)
      subject.constants.should include(const_foo)
    end
    it 'should keep track of variable declaration' do
      const_foo = mock('Constant')
      Ploc::Constant.should_receive(:new).with(:foo, 23).and_return(const_foo)
      
      subject.declare(:constant, :foo, 23).should == const_foo
    end
  end
  describe 'Building procedures' do
    it 'should allow to declare new procedures' do
      proc_foo = subject.declare(:procedure, :foo, 1000)
      subject.procedures.should include(proc_foo)
    end
    it 'should keep track of variable declaration' do
      proc_foo = mock('Constant')
      Ploc::Procedure.should_receive(:new).with(:foo, 23).and_return(proc_foo)
      
      subject.declare(:procedure, :foo, 23).should == proc_foo
    end
  end
end