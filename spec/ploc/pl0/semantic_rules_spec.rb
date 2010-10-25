require 'spec_helper'
require 'stringio'
require 'ploc/pl0/language'

module Ploc::PL0
  describe SemanticRules do
    before(:each) do
      @context = CompilingContext.new
      Language.context_builder.stub(:call) {|source_code| @context.source_code=(source_code); source_code.context=(@context) }
    end
    it 'should notify context of the begining' do
      @context.should_receive :initialize_new_program!
      Language.compile StringIO.new(".")
    end
    it 'should notify context of the end after the begining' do
      @context.should_receive(:initialize_new_program!).ordered
      @context.should_receive(:complete_program).ordered
      Language.compile StringIO.new(".")
    end
    describe "Declaring constants" do
      it 'should allow to declare one constant' do
        # pending
        @context.should_receive(:declare_constant).with(identifier("V"), 3)
        Language.compile StringIO.new("CONST V = 3;.")
      end
      it 'should allow to declare multiple constants' do
        @context.should_receive(:declare_constant).with(identifier("V"), 3).ordered
        @context.should_receive(:declare_constant).with(identifier("W"), 5).ordered
        Language.compile StringIO.new("CONST V = 3, W = 5;.")
      end
    end
    describe "Declaring variables" do
      it 'should allow to declare one variable' do
        @context.should_receive(:declare_variable).with(identifier("V"))
        Language.compile StringIO.new("VAR V;.")
      end
      it 'should allow to declare multiple variables' do
        @context.should_receive(:declare_variable).with(identifier("V")).ordered
        @context.should_receive(:declare_variable).with(identifier("W")).ordered
        Language.compile StringIO.new("VAR V, W;.")
      end
    end
    describe "Declaring procedures" do
      it 'should allow to declare one procedure' do
        @context.should_receive(:declare_procedure).with(identifier("P"))
        Language.compile StringIO.new("PROCEDURE P;;.")
      end
    end
    it "should push operands in expressions" do
      @context.should_receive(:push_operand).with(operand("*")).ordered
      @context.should_receive(:push_operand).with(operand("+")).ordered
      @context.should_receive(:push_operand).with(operand("/")).ordered
      @context.stub(:top_operand).and_return(operand("+"))
      @context.stub(:pop_operand).and_return(operand("+"))
      Language.compile StringIO.new("Write(3 * 2 + 5 / 8).")
    end
    describe 'after factor' do
      describe 'when factor was a number' do
        it 'should push it to the stack' do
          @context.should_receive(:compile_mov_eax).with(3)
          @context.should_receive(:compile_push_eax)
          Language.compile StringIO.new("VAR X; X := 3.")
        end
      end
      describe 'when factor was a constant' do
        it 'should push the constant value' do
          @context.should_receive(:compile_mov_eax).with do |const|
            Ploc::Constant === const && const.value.should == 3
          end
          @context.should_receive(:compile_push_eax)
          Language.compile StringIO.new("CONST Z = 3; VAR X; X := Z.")
        end
      end
      describe 'when factor was a variable' do
        it 'should push the variable offset' do
          @context.should_receive(:compile_mov_eax).with do |var|
            Ploc::Variable === var && var.name.should == :Z
          end
          @context.should_receive(:compile_push_eax)
          Language.compile StringIO.new("VAR X, Z; X := Z.")
        end
      end
    end
    context 'assignments' do
      it 'updates var content' do
        @context.should_receive(:compile_mov_var_eax).with do |var|
          Ploc::Variable === var && var.name.should == :X
        end
        Language.compile StringIO.new("VAR X, Z; X := Z.")
      end
    end
    context 'with multiples terms' do
      it 'pops operands and adds them' do
        @context.should_receive(:compile_mov_eax).with(3).ordered
        @context.should_receive(:compile_push_eax).ordered
        @context.should_receive(:compile_mov_eax).with(5).ordered
        @context.should_receive(:compile_push_eax).ordered
        @context.should_receive(:compile_operate_with_stack).with(operand('+')).ordered
        Language.compile StringIO.new("VAR X; X := 3 + 5.")
      end
      it 'pops operands and substracts them' do
        @context.should_receive(:compile_mov_eax).with(3).ordered
        @context.should_receive(:compile_push_eax).ordered
        @context.should_receive(:compile_mov_eax).with(5).ordered
        @context.should_receive(:compile_push_eax).ordered
        @context.should_receive(:compile_operate_with_stack).with(operand('-')).ordered
        Language.compile StringIO.new("VAR X; X := 3 - 5.")
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
        Language.compile StringIO.new("VAR X; X := 3 - 5 + 9.")
      end
    end
    context 'with multiples factors' do
      it 'pops operands and then multiplies them' do
        @context.should_receive(:compile_mov_eax).with(3).ordered
        @context.should_receive(:compile_push_eax).ordered
        @context.should_receive(:compile_mov_eax).with(5).ordered
        @context.should_receive(:compile_push_eax).ordered
        @context.should_receive(:compile_operate_with_stack).with(operand('*')).ordered
        Language.compile StringIO.new("VAR X; X := 3 * 5.")
      end
      it 'pops operands and then divides them' do
        @context.should_receive(:compile_mov_eax).with(3).ordered
        @context.should_receive(:compile_push_eax).ordered
        @context.should_receive(:compile_mov_eax).with(5).ordered
        @context.should_receive(:compile_push_eax).ordered
        @context.should_receive(:compile_operate_with_stack).with(operand('/')).ordered
        Language.compile StringIO.new("VAR X; X := 3 / 5.")
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
        Language.compile StringIO.new("VAR X; X := 3 * 5 / 9.")
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
        Language.compile StringIO.new("VAR X; X := 3 * 5 + 18 / 9 - 8.")
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
  end
end