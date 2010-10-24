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
        @context.should_receive(:declare_constant).with(identifier("V"), number(3))
        Language.compile StringIO.new("CONST V = 3;.")
      end
      it 'should allow to declare multiple constants' do
        @context.should_receive(:declare_constant).with(identifier("V"), number(3)).ordered
        @context.should_receive(:declare_constant).with(identifier("W"), number(5)).ordered
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
      Language.compile StringIO.new("Write(3 * 2 + 5 / 8).")
    end
    describe 'after factor' do
      describe 'when factor was a number'
        it 'should push it to the stack' do
          @context.should_receive(:compile_mov_eax).with(3)
          @context.should_receive(:compile_push_eax)
          Language.compile StringIO.new("VAR X; X := 3.")
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