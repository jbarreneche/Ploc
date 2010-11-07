require 'ploc/binary_data'
require 'ploc/fixable_output'
require 'ploc/output_optimizer'
require 'ploc/semantic_context'
require 'ploc/variable'
require 'forwardable'
require 'stringio'

module Ploc::PL0
  class CompilingContext < Ploc::SemanticContext
    ASSEMBLY_INSTRUCTIONS = {
      mov_eax_num: 'B8', mov_eax_edi_plus_offset: '8B 87',
      mov_var_eax: '89 87', mov_edi: 'BF',
      mov_ecx_num: 'B9', mov_edx_num: 'BA',
      jpo: '7B', je: '74', jne: '75', jg: '7F', jge: '7D', jl: '7C', jle: '7E',
      call: 'E8', jmp: 'E9', ret: 'C3',
      # Simple compile instructions
      push_eax: '50', pop_eax: '58', pop_ebx: '5B', xchg_eax_ebx: '93', cmp_eax_ebx: '39 C3',
      imul_ebx: 'F7 EB', idiv_ebx: 'F7 FB', add_eax_ebx: '01 D8', sub_eax_ebx: '29 D8',
      test_eax_oddity: 'A8 01', neg_eax: 'F7 D8', cltd: '99'
    }
    SIMPLE_COMPILE_INSTRUCTIONS = %w[ret push_eax pop_eax pop_ebx xchg_eax_ebx cmp_eax_ebx imul_ebx idiv_ebx add_eax_ebx sub_eax_ebx test_eax_oddity neg_eax cltd]
    PRECOMPILED_FUNCTIONS = {
      write_str: 0x0090, writeln: 0x00a0, write_number: 0x00b0, exit_prg: 0x0220, read_number: 0x0230
    }
    extend Forwardable
    attr_reader :output
    def_delegator :@operands, :<<, :push_operand
    def_delegator :@operands, :pop, :pop_operand
    def_delegator :@operands, :last, :top_operand
    def_delegator :@boolean_operands, :<<, :push_boolean_operand
    def_delegator :@boolean_operands, :pop, :pop_boolean_operand
    def_delegator :@boolean_operands, :last, :top_boolean_operand
    def initialize(source_code = nil, output = StringIO.new)
      super(source_code)
      @output = Ploc::FixableOutput.new(output)
      # @output = Ploc::FixableOutput.new(Ploc::OutputOptimizer.new(output))
      @operands = []
      @boolean_operands = []
      @pending_fix_jumps = []
    end
    def initialize_new_program!
      part_1, part_2, part_3 = File.read('support/elf_header').split(/\$\(\w+\)/)
      self.output << Ploc::BinaryData.new(part_1)
      @file_size_fixup = self.output.write_later(8)
      self.output << Ploc::BinaryData.new(part_2)
      @text_size_fixup = self.output.write_later(4)
      self.output << Ploc::BinaryData.new(part_3)

      # Starting text section
      @text_size_start = self.output.size
      self.output_to_text_section File.read('support/input_output_rutines')
      self.output_to_text_section ASSEMBLY_INSTRUCTIONS[:mov_edi]
      @edi_offset_fixup = self.write_later_in_text_section(4)
    end
    def complete_program
      # Jump to exit routine
      compile_jmp(io_function_address(:exit_prg))
      @edi_offset_fixup.fix(Ploc::BinaryData.new(current_text_address))
      @file_size_fixup.fix(Ploc::BinaryData.new(self.output.size, self.output.size))
      @text_size_fixup.fix(Ploc::BinaryData.new(text_output_size))
      self.output << Ploc::BinaryData.new("00 00 00 00\n" * (@var_sequence + 1))
      self.output.close
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
    def compile_mov_ecx(value)
      self.output_to_text_section ASSEMBLY_INSTRUCTIONS[:mov_ecx_num], value
    end
    def compile_mov_edx(value)
      self.output_to_text_section ASSEMBLY_INSTRUCTIONS[:mov_edx_num], value
    end
    def starting_text_address
      # # 0x0390
      @starting_text_address ||= Ploc::Address.new(0x080480e0)
    end
    def current_text_address
      starting_text_address + text_output_size
    end
    def write_later_in_text_section(size)
      self.output.write_later(size)
    end
    def output_to_text_section(*args)
      raw_output_to_text_section Ploc::BinaryData.new(*args)
    end
    def compile_negate_stack
      compile_pop_eax
      compile_neg_eax
      compile_push_eax
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
      self.compile_call_address relative_address(procedure.address)
    end
    def compile_call_io_function(function)
      self.compile_call_address relative_address(io_function_address(function))
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
        self.compile_xchg_eax_ebx
        self.compile_cltd
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
      @pending_fix_jumps << [self.current_text_address, self.write_later_in_text_section(5)]
      @pending_fix_jumps.last.last
    end
    def compile_jmp(address)
      self.output_to_text_section ASSEMBLY_INSTRUCTIONS[:jmp], (address - (current_text_address + 5)).value
    end
    def compile_read_variable(variable)
      self.compile_call_io_function(:read_number)
      self.compile_mov_var_eax(variable)
    end
    def fix_jmp(address = current_text_address)
      jump_from, fixable_point = @pending_fix_jumps.pop
      jump_correction = address - (jump_from  + 5)
      if jump_correction != 0
        fixable_point.fix(Ploc::BinaryData.new(ASSEMBLY_INSTRUCTIONS[:jmp], jump_correction))
      else
        fixable_point.destroy
      end
    end
    def compile_write_string(string)
      compile_mov_ecx((current_text_address + 20).value) # 5 de mov_ecx + 5 de mov_edx + 5 call_io + 5 jmp over string
      compile_mov_edx string.size
      compile_call_io_function :write_str
      compile_jmp current_text_address + string.size + 5
      raw_output_to_text_section string
    end
    def compile_write_eax
      compile_pop_eax
      compile_call_io_function :write_number
    end
    def compile_write_line
      compile_call_io_function :writeln
    end
  private
    def text_output_size
      output.size - @text_size_start
    end
    def relative_address(address)
      address - (current_text_address + 5)
    end
    def io_function_address(function)
      starting_text_address + PRECOMPILED_FUNCTIONS[function]
    end
    def raw_output_to_text_section(bin_data)
      self.output << bin_data.to_s
    end
  end
end