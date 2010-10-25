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
    Syntax.after_each(:declare_procedure) do |sequence_tokens, source_code|
      _, procedure_name = sequence_tokens
      source_code.context.declare_procedure(procedure_name)
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
  end
end