require 'ploc/identifier'

module Ploc
  class Constant < Identifier
    attr_reader :value
    def initialize(name, value)
      super(name)
      @value = value
    end
  end
end