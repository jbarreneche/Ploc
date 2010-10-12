module Ploc
  class SemanticContext
    def initialize
      @current_scope = Scope.new
    end
    def constants
      @current_scope.constants
    end
    def variables
      @current_scope.variables
    end
    def procedures
      @current_scope.procedures
    end
    def declare(type, name)
      @current_scope.declare(type, name)
    end
  end
end