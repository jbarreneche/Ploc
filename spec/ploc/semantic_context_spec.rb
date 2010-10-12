require 'spec_helper'
require 'ploc/semantic_context'

describe Ploc::SemanticContext do
  it { should have(0).constants }
  it { should have(0).variables }
  it { should have(0).procedures }
  it 'should allow to declare new variables' do
    var_foo = subject.declare(:variable, :foo)
    subject.variables.should include(var_foo)
  end
end