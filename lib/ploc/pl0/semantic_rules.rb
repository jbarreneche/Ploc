require 'ploc/pl0/syntax'
require 'ploc/token'
module Ploc::PL0
  module SemanticRules
    def self.debug(text)
      puts text
    end
    Syntax.before(:program) do |source_code|
      source_code.context.initialize_new_program!
    end
    Syntax.after(:program) do |tokens, source_code|
      source_code.context.complete_program
    end
    Syntax.after_each(:declare_constants) do |sequence_tokens, source_code|
      constant_name, _, value = sequence_tokens
      source_code.context.declare_constant(constant_name, value.to_i)
    end
    Syntax.after_each(:declare_variables) do |sequence_tokens, source_code|
      variable_name, _ = sequence_tokens
      source_code.context.declare_variable(variable_name)
    end
    Syntax.after(:procedure) do |_, source_code|
      context = source_code.context
      procedure_name = source_code.current_token
      context.declare_procedure(procedure_name, context.current_text_address)
    end
    Syntax.before(:procedure_block) do |source_code|
      context = source_code.context
      context.start_new_scope
    end
    Syntax.before(:block) do |source_code|
      source_code.context.compile_fixable_jmp
    end
    Syntax.after(:block_declarations) do |_, source_code|
      source_code.context.fix_jmp 
    end
    Syntax.after(:procedure_block) do |block_tokens, source_code|
      context = source_code.context
      context.compile_ret
      context.close_scope
    end
    Syntax.after(:ration) do |operand, source_code|
      source_code.context.push_operand operand
    end
    Syntax.after(:sign) do |operand, source_code|
      source_code.context.push_operand operand
    end
    Syntax.after(:factor) do |factor, source_code|
      factor = factor.first
      context = source_code.context
      case factor
      when Ploc::Token::Number
        context.compile_mov_eax(factor.token)
        context.compile_push_eax
      when Ploc::Token::Identifier
        identifier = context.retrieve_constant_or_variable(factor.token)
        context.compile_mov_eax(identifier)
        context.compile_push_eax
      end
    end
    Syntax.after_each(:term) do |_, source_code|
      context = source_code.context
      if context.top_operand && Ploc::Token::Operand::RATIONS.include?(context.top_operand.token)
        context.compile_operate_with_stack(context.pop_operand)
      end
    end
    Syntax.after_each(:more_expressions) do |_, source_code|
      context = source_code.context
      raise "Ups, top operand isn't a sign :S" unless context.top_operand && Ploc::Token::Operand::SIGNS.include?(context.top_operand.token)
      context.compile_operate_with_stack(context.pop_operand)
    end
    Syntax.after(:assignment) do |assignment, source_code|
      assigned_var_token, _ = assignment
      context = source_code.context
      assigned_variable = context.retrieve_variable(assigned_var_token.token)
      context.compile_assign_var_with_stack(assigned_variable)
    end
    Syntax.after(:call_procedure) do |(call, procedure_identifier), source_code|
      context = source_code.context
      procedure = context.retrieve_procedure(procedure_identifier.token)
      context.compile_call_procedure(procedure)
    end
    Syntax.after(:odd) do |odd, source_code|
      source_code.context.push_boolean_operand(odd)
    end
    Syntax.after(:bop) do |bop, source_code|
      source_code.context.push_boolean_operand(bop)
    end
    Syntax.after(:condition) do |condition, source_code|
      context = source_code.context
      bop = context.pop_boolean_operand
      context.compile_pop_eax
      if bop == 'ODD'
        context.compile_test_eax_oddity
      else
        context.compile_pop_ebx
        context.compile_cmp_eax_ebx
      end
      context.compile_skip_jump(bop)
      context.compile_fixable_jmp
    end
    Syntax.after(:branch) do |branch, source_code|
      context = source_code.context
      context.fix_jmp(context.current_text_address)
    end
    Syntax.around(:loop) do |source_code, &block|
      context = source_code.context
      condition_address = context.current_text_address
      block.call(source_code)
      context.compile_jmp(condition_address)
      context.fix_jmp(context.current_text_address)
    end
    Syntax.after(:input) do |read_tokens, source_code|
      _, _, variable_name, _ = read_tokens
      context = source_code.context
      variable = context.retrieve_variable(variable_name.token)
      context.compile_read_variable(variable)
    end
    Syntax.after(:output_expression) do |output, source_code|
      context = source_code.context
      if Ploc::Token::String === output.first
        context.compile_write_string(output.first.token)
      else
        context.compile_write_eax
      end
    end
    Syntax.after(:output_line) do |writeln, source_code|
      source_code.context.compile_write_line
    end
  end
end