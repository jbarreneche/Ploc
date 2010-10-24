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
    describe 'compiling instructions' do
      # MOV EAX, 3 === B8\x3\0\0\0\
      it 'should output mov_eax(number) as B8 number' do
        subject.output.should_receive(:<<).with("\xB8\x3\0\0\0")
        subject.compile_mov_eax(3)
      end
      # PUSH EAX === 50
      it 'should output push_eax as 50' do
        subject.output.should_receive(:<<).with("\x50")
        subject.compile_push_eax
      end
    end
  end
end