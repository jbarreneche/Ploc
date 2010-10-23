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
        Language.compile StringIO.new("CONST V = 3.")
      end
      it 'should allow to declare multiple constants' do
        @context.should_receive(:declare_constant).with(identifier("V"), number(3)).ordered
        @context.should_receive(:declare_constant).with(identifier("W"), number(5)).ordered
        Language.compile StringIO.new("CONST V = 3, W = 5.")
      end
    end
    describe "Declaring variables" do
      it 'should allow to declare one variable' do
        @context.should_receive(:declare_variable).with(identifier("V"))
        Language.compile StringIO.new("VAR V.")
      end
      it 'should allow to declare multiple variables' do
        pending
        @context.should_receive(:declare_variable).with("V").ordered
        @context.should_receive(:declare_variable).with("W").ordered
        Language.compile StringIO.new("CONST V, W.")
      end
    end
    describe "Declaring procedures" do
      it 'should allow to declare one procedure' do
        pending
        @context.should_receive(:declare_procedure).with("P")
        Language.compile StringIO.new("PROCEDURE P;;.")
      end
    end
    def identifier(v)
      Ploc::Token::Identifier.new v
    end
    def number(n)
      Ploc::Token::Number.new n
    end
  end
end