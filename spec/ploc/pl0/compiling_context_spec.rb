require 'spec_helper'
require 'ploc/pl0/compiling_context'

module Ploc::PL0
  describe CompilingContext do
    its(:output) { should be_empty }
    it 'should output header when initializing new program' do
      pending('still not sure about how to implement fixups...')
      subject.output.should_receive(:<<)
    end
    it 'should allow to push operands and retrieve them with pop' do
      subject.push_operand :operand
      subject.pop_operand.should == :operand
    end
  end
end