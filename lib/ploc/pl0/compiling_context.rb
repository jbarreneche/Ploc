require 'ploc/semantic_context'
require 'ploc/binary_data'
require 'ploc/variable'
require 'ploc/fixable_output'
require 'forwardable'
module Ploc::PL0
  class CompilingContext < Ploc::SemanticContext
    ASSEMBLY_INSTRUCTIONS = {
      mov_eax_num: 'B8', mov_eax_edi_plus_offset: '8B 87',
      mov_var_eax: '89 87',
      jpo: '7B', je: '74', jne: '75', jg: '7F', jge: '7D', jl: '7C', jle: '7E',
      call: 'E8', jmp: 'E9',
      # Simple compile instructions
      push_eax: '50', pop_eax: '58', pop_ebx: '5B', xchg_eax_ebx: '93', cmp_eax_ebx: '39 C3',
      imul_ebx: 'F7 FB', idiv_ebx: 'F7 EB', add_eax_ebx: '01 D8', sub_eax_ebx: '29 D8',
      test_eax_oddity: 'A8 01'
    }
    SIMPLE_COMPILE_INSTRUCTIONS = %w[push_eax pop_eax pop_ebx xchg_eax_ebx cmp_eax_ebx imul_ebx idiv_ebx add_eax_ebx sub_eax_ebx test_eax_oddity]

    extend Forwardable
    attr_reader :output
    def_delegator :@operands, :<<, :push_operand
    def_delegator :@operands, :pop, :pop_operand
    def_delegator :@operands, :last, :top_operand
    def_delegator :@boolean_operands, :<<, :push_boolean_operand
    def_delegator :@boolean_operands, :pop, :pop_boolean_operand
    def_delegator :@boolean_operands, :last, :top_boolean_operand
    def initialize(source_code = nil)
      super(source_code)
      @output = Ploc::FixableOutput.new([])
      @operands = []
      @boolean_operands = []
      @text_output_size = 0
      @pending_fix_jumps = []
    end
    def initialize_new_program!
      part_1, part_2, part_3 = File.read('support/elf_header').split(/\$\(\w+\)/)
      self.output << part_1
      @file_size_fixup = self.output.write_later(4)
      self.output << part_2
      @text_size_fixup = self.output.write_later(4)
      self.output << part_3
    end
    def complete_program
      @file_size_fixup.fix(Ploc::BinaryData.new(self.output.size))
      @text_size_fixup.fix(Ploc::BinaryData.new(@text_output_size))
    end
    def compile_mov_eax(value)
      case value
      when Fixnum
        self.output_to_text_section ASSEMBLY_INSTRUCTIONS[:mov_eax_num], value
      when Ploc::Constant
        self.compile_mov_eax(value.value)
      when Ploc::Variable
        self.output_to_text_section ASSEMBLY_INSTRUCTIONS[:mov_eax_edi_plus_offset], value.offset.value
      end
    end
    def starting_text_address
      @starting_text_address ||= Ploc::Address.new(0x08048480)
    end
    def current_text_address
      starting_text_address + @text_output_size
    end
    def output_to_text_section(*args)
      bin_data = Ploc::BinaryData.new(*args)
      @text_output_size += bin_data.size
      self.output << bin_data.to_s
    end
    SIMPLE_COMPILE_INSTRUCTIONS.each do |asm_instruction|
      define_method("compile_#{asm_instruction}") do
        self.output_to_text_section ASSEMBLY_INSTRUCTIONS[asm_instruction.to_sym]
      end
    end
    def compile_mov_var_eax(var)
      self.output_to_text_section ASSEMBLY_INSTRUCTIONS[:mov_var_eax], var.offset.value
    end
    def compile_assign_var_with_stack(var)
      self.compile_pop_eax
      self.compile_mov_var_eax(var)
    end
    def compile_call_procedure(procedure)
      self.compile_call_address procedure.address - (current_text_address + 5)
    end
    def compile_call_address(address)
      self.output_to_text_section ASSEMBLY_INSTRUCTIONS[:call],  address.value
    end
    def compile_skip_jump(operand)
      case operand.token.downcase
      when 'odd'
        self.output_to_text_section ASSEMBLY_INSTRUCTIONS[:jpo], "05"
      when '='
        self.output_to_text_section ASSEMBLY_INSTRUCTIONS[:je], "05"
      when '<>'
        self.output_to_text_section ASSEMBLY_INSTRUCTIONS[:jne], "05"
      when '>'
        self.output_to_text_section ASSEMBLY_INSTRUCTIONS[:jg], "05"
      when '>='
        self.output_to_text_section ASSEMBLY_INSTRUCTIONS[:jge], "05"
      when '<'
        self.output_to_text_section ASSEMBLY_INSTRUCTIONS[:jl], "05"
      when '<='
        self.output_to_text_section ASSEMBLY_INSTRUCTIONS[:jle], "05"
      end
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
    def compile_fixable_jmp
      self.output_to_text_section ASSEMBLY_INSTRUCTIONS[:jmp]
      @pending_fix_jumps << [self.current_text_address, self.output.write_later(4)]
    end
    def fix_jmp(address)
      jump_from, fixable_point = @pending_fix_jumps.pop
      fixable_point.fix(jump_from - address + 5)
    end
  end
end