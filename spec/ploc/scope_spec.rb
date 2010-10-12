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
end