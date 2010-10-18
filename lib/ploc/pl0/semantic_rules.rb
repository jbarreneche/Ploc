require 'ploc/pl0/syntax'

module Ploc::PL0
  module SemanticRules
    def self.debug(text)
      puts text
    end
    Syntax.before(:program) do |current_token, source_code|
      source_code.context.initialize_new_program!
    end
    Syntax.after(:program) do |next_token, current_token, source_code|
      source_code.context.complete_program
    end
  end
end