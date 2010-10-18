require 'spec_helper'
require 'stringio'
require 'ploc/pl0/language'

module Ploc::PL0
  describe SemanticRules do
    it 'should notify context of the begining and ending of the program' do
      context = CompilingContext.new
      Language.context_builder.stub(:call) {|source_code| context.source_code=(source_code); source_code.context=(context) }
      context.should_receive :initialize_new_program!
      context.should_receive :complete_program
      Language.compile StringIO.new(".")
    end
  end
end