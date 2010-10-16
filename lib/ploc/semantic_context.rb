require 'ploc/constant'
require 'ploc/procedure'
require 'ploc/scope'
require 'ploc/variable'

module Ploc
  class SemanticContext
    attr_reader :scope
    def initialize
      @scope = Scope.new(self)
      @var_sequence = -1
    end
    def constants
      @scope.constants
    end
    def variables
      @scope.variables
    end
    def procedures
      @scope.procedures
    end
    def declare(type, name, *args)
      @scope.declare(type, name, *args)
    end
    def build_variable(name)
      Variable.new name, next_var_sequence
    end
    def build_constant(name, value)
      Constant.new name, value
    end
    def build_procedure(name, address)
      Procedure.new name, address
    end
  private
    def next_var_sequence
      @var_sequence += 1
    end
  end
end