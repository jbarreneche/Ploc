require 'ploc/compiler'

module Ploc::PL0
  class Compiler < Ploc::Complier
    def initialize(scanner)
      super(scanner, Ploc::SemanticContext.new)
    end
  end
end