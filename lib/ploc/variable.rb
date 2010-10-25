require 'ploc/identifier'

module Ploc
  class Variable < Identifier
    attr_reader :offset
    def initialize(name, offset)
      super(name)
      @offset = offset
    end
  end
end