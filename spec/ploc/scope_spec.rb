require 'spec_helper'
require 'ploc/scope'

describe Ploc::Scope do
  it { should have(0).constants }
  it { should have(0).variables }
  it { should have(0).procedures }
  it { subject.parent.should be_nil }
  context 'declaring variables' do
    it 'should allow to declare variables' do
      foo_var = subject.declare(:variable, :foo)
      subject.should have(1).variables
      subject.variables.should include(foo_var)
    end
    it 'should\'nt allow to declare already declared variables' do
      foo_var = subject.declare(:variable, :foo)
      lambda {
        subject.declare(:variable, :foo)
      }.should raise_error(Ploc::DuplicateDeclarationError)
    end
  end
  context 'declaring constants' do
    it 'should allow to declare variables' do
      foo_cons = subject.declare(:constant, :foo)
      subject.should have(1).constants
      subject.constants.should include(foo_cons)
    end
    it 'should\'nt allow to declare already declared variables' do
      foo_cons = subject.declare(:constant, :foo)
      lambda {
        subject.declare(:constant, :foo)
      }.should raise_error(Ploc::DuplicateDeclarationError)
    end
  end
  context 'declaring procedures' do
    it 'should allow to declare procedures' do
      foo_proc = subject.declare(:procedure, :foo)
      subject.should have(1).procedures
      subject.procedures.should include(foo_proc)
    end
    it 'should\'nt allow to declare already declared procedures' do
      foo_proc = subject.declare(:procedure, :foo)
      lambda {
        subject.declare(:procedure, :foo)
      }.should raise_error(Ploc::DuplicateDeclarationError)
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
end