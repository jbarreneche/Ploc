require 'ploc/pl0/syntax'

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
    # Syntax.after_each(:declare_constants) do |next_token, sequence_tokens, source_code|
    #   constant_name, _, value = sequence_tokens
    #   source_code.context.declare_constant(constant_name, value)
    # end
  end
end