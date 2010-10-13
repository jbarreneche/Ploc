module Ploc
  class Identifier
    attr_reader :name
    def initialize(name)
      @name = name.to_sym
    end
    def ==(o)
      return self.name == o if Symbol === o
      super
    end
  end
end