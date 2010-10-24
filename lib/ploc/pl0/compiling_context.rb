# encoding: utf-8
require 'ploc/semantic_context'
require 'ploc/binary_data'
require 'forwardable'
module Ploc::PL0
  class CompilingContext < Ploc::SemanticContext
    extend Forwardable
    attr_reader :output
    def_delegator :@operands, :<<, :push_operand
    def_delegator :@operands, :pop, :pop_operand
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
    def compile_mov_eax(number)
      self.output << Ploc::BinaryData.new("B8", number).to_s
    end
    def compile_push_eax
      self.output << Ploc::BinaryData.new("50").to_s
    end
  end
end