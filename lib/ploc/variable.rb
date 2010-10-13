require 'ploc/identifier'

module Ploc
  class Variable < Identifier
    attr_reader :sequence
    def initialize(name, sequence)
      super(name)
      @sequence = sequence
    end
  end
end