require 'spec_helper'
require 'stringio'
require 'ploc/address'
require 'ploc/pl0/language'

module Ploc::PL0
  describe SemanticRules do
    let(:address) { Ploc::Address.new(rand(50)) }
    let(:empty_program) { StringIO.new(".") }
    let(:constant) { mock('Constant') }
    let(:variable) { mock('Variable') }
    before(:each) do
      @context = CompilingContext.new
      Language.context_builder.stub(:call) {|source_code| @context.source_code=(source_code); source_code.context=(@context) }
    end
    it 'notifies the begining of the program' do
      @context.should_receive(:initialize_new_program!)
      @context.stub(:complete_program)
      Language.compile empty_program
    end
    it 'notifies the program completition after the begining' do
      @context.should_receive(:initialize_new_program!).ordered
      @context.should_receive(:complete_program).ordered
      Language.compile empty_program
    end
    describe "Constants" do
      context 'Declaration' do
        it 'allows to declare one constant with its value' do
          @context.should_receive(:declare_constant).with(identifier("V"), 3)
          Language.compile StringIO.new("CONST V = 3;.")
        end
        it 'allows to declare multiple constants with their own value' do
          @context.should_receive(:declare_constant).with(identifier("V"), 3).ordered
          @context.should_receive(:declare_constant).with(identifier("W"), 5).ordered
          Language.compile StringIO.new("CONST V = 3, W = 5;.")
        end
      end
      context 'Using constants in expressions' do
        it 'retrieves them from the context and pushes them to the stack so they can be used' do
          @context.should_receive(:retrieve_constant_or_variable).with("foo") { constant }.ordered
          @context.should_receive(:compile_mov_eax).with(constant).ordered
          @context.should_receive(:compile_push_eax).ordered
          Language.compile StringIO.new("WRITE(foo).")
        end
      end
      context "Using inline constants in expressions" do
        it 'pushes them as if they where constants' do
          @context.should_receive(:compile_mov_eax).with(3).ordered
          @context.should_receive(:compile_push_eax).ordered
          Language.compile StringIO.new("WRITE (3.")
        end
      end
    end
    describe "Variables" do
      context 'Declaration' do
        it 'allows to declare one variable' do
          @context.should_receive(:declare_variable).with(identifier("V"))
          Language.compile StringIO.new("VAR V;.")
        end
        it 'allows to declare multiple variables' do
          @context.should_receive(:declare_variable).with(identifier("V")).ordered
          @context.should_receive(:declare_variable).with(identifier("W")).ordered
          Language.compile StringIO.new("VAR V, W;.")
        end
      end
      context 'Assignation' do
        it 'retrieves the var from the context and updates its content' do
          @context.should_receive(:retrieve_variable).with("foo") { variable }.ordered
          @context.should_receive(:compile_mov_var_eax).with(variable).ordered
          Language.compile StringIO.new("foo := 3.")
        end
      end
    end
    describe "Procedures" do
      context "Declaration" do
        it 'should allow to declare one procedure' do
          @context.stub(:current_text_address) { address }
          @context.should_receive(:declare_procedure).with(identifier("P"), address)
          Language.compile StringIO.new("PROCEDURE P;;.")
        end
        it 'should create a new scope and then clear it out' do
          @context.should_receive(:start_new_scope).ordered
          @context.should_receive(:close_scope).ordered
          Language.compile StringIO.new("PROCEDURE P;;.")
        end
      end
      context 'Calling' do
        it 'compiles to the procedure call' do
          procedure = mock('Procedure')
          @context.should_receive(:retrieve_procedure).with('foo') { procedure }
          @context.should_receive(:compile_call_procedure).with(procedure)
          Language.compile StringIO.new("CALL foo.")
        end
      end
    end
    describe 'Expressions' do
      it "pushes operands in the right order" do
        @context.should_receive(:push_operand).with(operand("*")).ordered
        @context.should_receive(:push_operand).with(operand("+")).ordered
        @context.should_receive(:push_operand).with(operand("/")).ordered
        @context.stub(:top_operand).and_return(operand("+"))
        @context.stub(:pop_operand).and_return(operand("+"))
        Language.compile StringIO.new("WRITE (3 * 2 + 5 / 8).")
      end
      context 'with multiples terms' do
        it 'pops operands and adds them' do
          @context.should_receive(:compile_mov_eax).with(3).ordered
          @context.should_receive(:compile_push_eax).ordered
          @context.should_receive(:compile_mov_eax).with(5).ordered
          @context.should_receive(:compile_push_eax).ordered
          @context.should_receive(:compile_operate_with_stack).with(operand('+')).ordered
          Language.compile StringIO.new("WRITE (3 + 5).")
        end
        it 'pops operands and substracts them' do
          @context.should_receive(:compile_mov_eax).with(3).ordered
          @context.should_receive(:compile_push_eax).ordered
          @context.should_receive(:compile_mov_eax).with(5).ordered
          @context.should_receive(:compile_push_eax).ordered
          @context.should_receive(:compile_operate_with_stack).with(operand('-')).ordered
          Language.compile StringIO.new("WRITE (3 - 5).")
        end
        it 'handles multiple operands and their operations' do
          @context.should_receive(:compile_mov_eax).with(3).ordered
          @context.should_receive(:compile_push_eax).ordered
          @context.should_receive(:compile_mov_eax).with(5).ordered
          @context.should_receive(:compile_push_eax).ordered
          @context.should_receive(:compile_operate_with_stack).with(operand('-')).ordered
          @context.should_receive(:compile_mov_eax).with(9).ordered
          @context.should_receive(:compile_push_eax).ordered
          @context.should_receive(:compile_operate_with_stack).with(operand('+')).ordered
          Language.compile StringIO.new("WRITE (3 - 5 + 9).")
        end
      end
      context 'with multiples factors' do
        it 'pops operands and then multiplies them' do
          @context.should_receive(:compile_mov_eax).with(3).ordered
          @context.should_receive(:compile_push_eax).ordered
          @context.should_receive(:compile_mov_eax).with(5).ordered
          @context.should_receive(:compile_push_eax).ordered
          @context.should_receive(:compile_operate_with_stack).with(operand('*')).ordered
          Language.compile StringIO.new("WRITE (3 * 5).")
        end
        it 'pops operands and then divides them' do
          @context.should_receive(:compile_mov_eax).with(3).ordered
          @context.should_receive(:compile_push_eax).ordered
          @context.should_receive(:compile_mov_eax).with(5).ordered
          @context.should_receive(:compile_push_eax).ordered
          @context.should_receive(:compile_operate_with_stack).with(operand('/')).ordered
          Language.compile StringIO.new("WRITE (3 / 5).")
        end
        it 'handles multiple operands and their operation' do
          @context.should_receive(:compile_mov_eax).with(3).ordered
          @context.should_receive(:compile_push_eax).ordered
          @context.should_receive(:compile_mov_eax).with(5).ordered
          @context.should_receive(:compile_push_eax).ordered
          @context.should_receive(:compile_operate_with_stack).with(operand('*')).ordered
          @context.should_receive(:compile_mov_eax).with(9).ordered
          @context.should_receive(:compile_push_eax).ordered
          @context.should_receive(:compile_operate_with_stack).with(operand('/')).ordered
          Language.compile StringIO.new("WRITE (3 * 5 / 9).")
        end
      end
      context 'with multiple factors and terms' do
        it 'just works!' do
          @context.should_receive(:compile_mov_eax).with(3).ordered
          @context.should_receive(:compile_push_eax).ordered
          @context.should_receive(:compile_mov_eax).with(5).ordered
          @context.should_receive(:compile_push_eax).ordered
          @context.should_receive(:compile_operate_with_stack).with(operand('*')).ordered
          @context.should_receive(:compile_mov_eax).with(18).ordered
          @context.should_receive(:compile_push_eax).ordered
          @context.should_receive(:compile_mov_eax).with(9).ordered
          @context.should_receive(:compile_push_eax).ordered
          @context.should_receive(:compile_operate_with_stack).with(operand('/')).ordered
          @context.should_receive(:compile_operate_with_stack).with(operand('+')).ordered
          @context.should_receive(:compile_mov_eax).with(8).ordered
          @context.should_receive(:compile_push_eax).ordered
          @context.should_receive(:compile_operate_with_stack).with(operand('-')).ordered
          Language.compile StringIO.new("WRITE (3 * 5 + 18 / 9 - 8).")
        end
      end
    end
    describe 'Conditions' do
      context 'with ODD operand' do
        it 'pushes ODD as a boolean operand' do
          @context.should_receive(:push_boolean_operand).with(reserved_word('ODD'))
          @context.stub(:pop_boolean_operand) {reserved_word('ODD')}
          Language.compile StringIO.new('if ODD 3 then write("3 is odd!! :D").')
        end
        it 'compiles to 58 A8 01 7B 05 E9 00 00 00 00' do
          @context.should_receive(:compile_pop_eax)
          @context.should_receive(:compile_test_eax_oddity)
          @context.should_receive(:compile_skip_jump).with(reserved_word('ODD'))
          @context.should_receive(:compile_fixable_jmp)
          Language.compile StringIO.new('if ODD 3 then write("3 is odd!! :D").')
        end
      end
      context 'with boolean operators between two expressions' do
        it 'pushes the boolean operator as a boolean operand' do
          @context.should_receive(:push_boolean_operand).with(operand('='))
          @context.stub(:pop_boolean_operand) {operand('=')}
          Language.compile StringIO.new('if 3 = 5 then write("3 equals 5, AWESOME! :D").')
        end
        it 'compiles to 58 5B 39 C3 (#condition operand) E9 00 00 00 00' do
          @context.should_receive(:compile_pop_eax)
          @context.should_receive(:compile_pop_ebx)
          @context.should_receive(:compile_cmp_eax_ebx)
          @context.should_receive(:compile_skip_jump).with(operand('='))
          @context.should_receive(:compile_fixable_jmp)
          Language.compile StringIO.new('if 3 = 5 then write("3 equals 5, AWESOME! :D").')
        end
      end
    end
    def identifier(v)
      Ploc::Token::Identifier.new v
    end
    def number(n)
      Ploc::Token::Number.new n
    end
    def operand(op)
      Ploc::Token::Operand.new op
    end
    def reserved_word(word)
      Ploc::Token::ReservedWord.new word
    end
  end
end