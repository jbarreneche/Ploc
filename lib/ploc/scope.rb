module Ploc
  class DuplicateDeclarationError < StandardError; end
  class Scope
    def initialize
      @local_declarations_hash = {constants:[], variables: [], procedures: []}
    end
    def constants
      []
    end
    def variables
      local_variables + parent_variables
    end
    def procedures
      []
    end
    def parent
      @parent
    end
    def declare(type, value)
      declare_variable(value)
      value
    end
  private
    def declare_variable(value)
      raise DuplicateDeclarationError if local_declarations.include? value
      local_variables << value
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
    def local_declarations
      local_variables + local_procedures + local_constants
    end
    def local_declarations_hash
      @local_declarations_hash
    end
  end
end