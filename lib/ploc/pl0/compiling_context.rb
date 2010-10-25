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
      @text_output_size = 0
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
    def starting_text_address
      @starting_text_address ||= Ploc::Address.new(0x08048480)
    end
    def current_text_address
      starting_text_address + @text_output_size
    end
    def output_to_text_section(*args)
      args.each do |arg| 
        @text_output_size += arg.size
        self.output << arg
      end
    end
    def compile_push_eax
      self.output_to_text_section Ploc::BinaryData.new("50").to_s
    end
    def compile_pop_eax
      self.output_to_text_section Ploc::BinaryData.new("58").to_s
    end
    def compile_pop_ebx
      self.output_to_text_section Ploc::BinaryData.new("5B").to_s
    end
    def compile_imul_ebx
      self.output_to_text_section Ploc::BinaryData.new("F7 FB").to_s
    end
    def compile_idiv_ebx
      self.output_to_text_section Ploc::BinaryData.new("F7 EB").to_s
    end
    def compile_add_eax_ebx
      self.output_to_text_section Ploc::BinaryData.new("01 D8").to_s
    end
    def compile_sub_eax_ebx
      self.output_to_text_section Ploc::BinaryData.new("29 D8").to_s
    end
    def compile_xchg_eax_ebx
      self.output_to_text_section Ploc::BinaryData.new("93").to_s
    end
    def compile_mov_var_eax(var)
      self.output_to_text_section Ploc::BinaryData.new("89 87", var.offset.value).to_s
    end
    def compile_assign_var_with_stack(var)
      self.compile_pop_eax
      self.compile_mov_var_eax(var)
    end
    def compile_operate_with_stack(operand)
      self.compile_pop_eax
      self.compile_pop_ebx
      case operand.token
      when '*'
        self.compile_imul_ebx
      when '/'
        self.compile_idiv_ebx
      when '+'
        self.compile_add_eax_ebx
      when '-'
        self.compile_xchg_eax_ebx
        self.compile_sub_eax_ebx
      else
        raise 'Unknown operand...'
      end
      self.compile_push_eax
    end
  end
end