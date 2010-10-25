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
      # MOV EAX, 3 === B8 03 00 00 00
      it 'should output mov_eax(number) as B8 number' do
        subject.output.should_receive(:<<).with("\xB8\x3\0\0\0")
        subject.compile_mov_eax(3)
      end
      # MOV EAX, [EDI + 10] === 8B 87 0A 00 00 00
      it 'should output mov_eax(number) as 8B 87 number' do
        subject.output.should_receive(:<<).with("\x8B\x87\xA\0\0\0")
        subject.compile_mov_eax(Ploc::Variable.new(:foo, Ploc::Address.new(10)))
      end
      it 'should output push_eax as 50' do
        subject.output.should_receive(:<<).with("\x50")
        subject.compile_push_eax
      end
      it 'should output pop_eax as 58' do
        subject.output.should_receive(:<<).with("\x58")
        subject.compile_pop_eax
      end
      it 'should output imul_ebx as F7 FB' do
        subject.output.should_receive(:<<).with("\xF7\xFB")
        subject.compile_imul_ebx
      end
      it 'should output idiv_ebx as F7 EB' do
        subject.output.should_receive(:<<).with("\xF7\xEB")
        subject.compile_idiv_ebx
      end
    end
  end
end