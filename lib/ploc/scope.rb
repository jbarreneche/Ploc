module Ploc
  class DuplicateDeclarationError < StandardError; end
  class Scope
    def initialize(parent = nil)
      @parent = parent
      @local_declarations_hash = {constants:[], variables: [], procedures: []}
    end
    def constants
      local_constants + parent_constants
    end
    def variables
      local_variables + parent_variables
    end
    def procedures
      local_procedures + parent_procedures
    end
    def parent
      @parent
    end
    def declare(type, value)
      raise DuplicateDeclarationError if local_declarations.include? value
      case type
      when :variable
        declare_variable(value)
      when :constant
        declare_constant(value)
      else
        declare_procedure(value)
      end
      value
    end
    def build_subcontext
      Scope.new(self)
    end
  private
    def declare_variable(value)
      local_variables << value
    end
    def declare_constant(value)
      local_constants << value
    end
    def declare_procedure(value)
      local_procedures << value
    end
    def local_variables
      local_declarations_hash[:variables]
    end
    def local_constants
      local_declarations_hash[:constants]
    end
    def local_procedures
      local_declarations_hash[:procedures]
    end
    def parent_variables
      @parent ? @parent.variables : []
    end
    def parent_constants
      @parent ? @parent.constants : []
    end
    def parent_procedures
      @parent ? @parent.procedures : []
    end
    def local_declarations
      local_variables + local_procedures + local_constants
    end
    def local_declarations_hash
      @local_declarations_hash
    end
  end
end