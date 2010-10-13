require 'ploc/identifier'

module Ploc
  class Procedure < Identifier
    attr_reader :address
    def initialize(name, address)
      super(name)
      @address = address
    end
  end
end