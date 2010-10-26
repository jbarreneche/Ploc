require 'spec_helper'
require 'ploc/token'
require 'ploc/pl0/compiling_context'

module Ploc::PL0
  describe CompilingContext do
    its(:output) { should be_empty }
    let(:some_var) { Ploc::Variable.new(:foo, Ploc::Address.new(10)) }
    it 'should output header when initializing new program' do
      pending('still not sure about how to implement fixups...')
      subject.output.should_receive(:<<)
    end
    it 'should allow to push operands and retrieve them with pop' do
      subject.push_operand :operand
      subject.pop_operand.should == :operand
    end
    context ".compile_operate_with_stack" do
      it 'operates + as an add eax ebx' do
        subject.should_receive(:compile_pop_eax).ordered
        subject.should_receive(:compile_pop_ebx).ordered
        subject.should_receive(:compile_add_eax_ebx).ordered
        subject.should_receive(:compile_push_eax).ordered
        subject.compile_operate_with_stack(Ploc::Token::Operand.new('+'))
      end
      it 'operates - as an xchg eax; sub eax ebx' do
        subject.should_receive(:compile_pop_eax).ordered
        subject.should_receive(:compile_pop_ebx).ordered
        subject.should_receive(:compile_xchg_eax_ebx).ordered
        subject.should_receive(:compile_sub_eax_ebx).ordered
        subject.should_receive(:compile_push_eax).ordered
        subject.compile_operate_with_stack(Ploc::Token::Operand.new('-'))
      end
    end
    describe '.compile_assign_var_with_stack' do
      it 'pops eax and moves eax to the var' do
        subject.should_receive(:compile_pop_eax).ordered
        subject.should_receive(:compile_mov_var_eax).with(some_var).ordered
        subject.compile_assign_var_with_stack(some_var)
      end
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
      it 'should output pop_ebx as 5B' do
        subject.output.should_receive(:<<).with("\x5B")
        subject.compile_pop_ebx
      end
      it 'should output imul_ebx as F7 FB' do
        subject.output.should_receive(:<<).with("\xF7\xFB")
        subject.compile_imul_ebx
      end
      it 'should output idiv_ebx as F7 EB' do
        subject.output.should_receive(:<<).with("\xF7\xEB")
        subject.compile_idiv_ebx
      end
      it 'should output add_eax_ebx as 01 D8' do
        subject.output.should_receive(:<<).with("\x01\xD8")
        subject.compile_add_eax_ebx
      end
      it 'should output sub_eax_ebx as 29 D8' do
        subject.output.should_receive(:<<).with("\x29\xD8")
        subject.compile_sub_eax_ebx
      end
      it 'should output xchg_eax_ebx as 93' do
        subject.output.should_receive(:<<).with("\x93")
        subject.compile_xchg_eax_ebx
      end
      it 'should output mov_var_eax as 89 87 var' do
        subject.output.should_receive(:<<).with("\x89\x87\xA\0\0\0")
        subject.compile_mov_var_eax(Ploc::Variable.new(:foo, Ploc::Address.new(10)))
      end
      it 'compiles test_eax_oddity as A8 01' do
        subject.output.should_receive(:<<).with("\xA8\x01")
        subject.compile_test_eax_oddity
      end
      context '#compile_short_jump' do
        it 'compiles operand ODD as jpo(5)' do
          subject.output.should_receive(:<<).with("\x7B\x05")
          subject.compile_skip_jump(token('ODD'))
        end
        it 'compiles operand = as je(5)' do
          subject.output.should_receive(:<<).with("\x74\x05")
          subject.compile_skip_jump(token('='))
        end
        it 'compiles operand <> as jne(5)' do
          subject.output.should_receive(:<<).with("\x75\x05")
          subject.compile_skip_jump(token('<>'))
        end
        it 'compiles operand > as jg(5)' do
          subject.output.should_receive(:<<).with("\x7F\x05")
          subject.compile_skip_jump(token('>'))
        end
        it 'compiles operand >= as jge(5)' do
          subject.output.should_receive(:<<).with("\x7D\x05")
          subject.compile_skip_jump(token('>='))
        end
        it 'compiles operand < as jl(5)' do
          subject.output.should_receive(:<<).with("\x7C\x05")
          subject.compile_skip_jump(token('<'))
        end
        it 'compiles operand <= as jle(5)' do
          subject.output.should_receive(:<<).with("\x7E\x05")
          subject.compile_skip_jump(token('<='))
        end
      end
    end
    def token(str)
      mock('Token', token: str)
    end
  end
end