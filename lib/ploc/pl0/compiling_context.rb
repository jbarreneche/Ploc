# encoding: utf-8
require 'ploc/semantic_context'
require 'ploc/binary_data'
require 'ploc/variable'
require 'forwardable'
module Ploc::PL0
  class CompilingContext < Ploc::SemanticContext
    extend Forwardable
    attr_reader :output
    def_delegator :@operands, :<<, :push_operand
    def_delegator :@operands, :pop, :pop_operand
    def_delegator :@operands, :last, :top_operand
    def initialize(source_code = nil)
      super(source_code)
      @output = []
      @operands = []
    end
    def initialize_new_program!(*args)
      self.output << Ploc::BinaryData.new(File.read('support/elf_header'))
    end
    def complete_program(*args)
    end
    def compile_mov_eax(value)
      case value
      when Fixnum
        self.output << Ploc::BinaryData.new("B8", value).to_s
      when Ploc::Constant
        self.compile_mov_eax(value.value)
      when Ploc::Variable
        self.output << Ploc::BinaryData.new("8B 87", value.offset.value).to_s
      end
    end
    def compile_push_eax
      self.output << Ploc::BinaryData.new("50").to_s
    end
    def compile_pop_eax
      self.output << Ploc::BinaryData.new("58").to_s
    end
    def compile_imul_ebx
      self.output << Ploc::BinaryData.new("F7 FB").to_s
    end
    def compile_idiv_ebx
      self.output << Ploc::BinaryData.new("F7 EB").to_s
    end
    def compile_term_operation(operand)
      self.compile_pop_eax
      self.compile_pop_ebx
      if operand.token == '*'
        self.compile_imul_ebx
      else
        self.compile_idiv_ebx
      end
      self.compile_push_eax
    end
  end
end