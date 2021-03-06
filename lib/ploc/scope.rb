module Ploc
  class DuplicateDeclarationError < StandardError; end
  class UndeclaredIdentifierError < StandardError; end
  class WrongTypeDeclarationError < StandardError; end
  class Scope
    SUPPORTED_TYPES = [:constants, :variables, :procedures]
    attr_reader :context
    def initialize(context, parent = nil)
      @context = context
      @parent = parent
      @local_declarations_hash = Hash[SUPPORTED_TYPES.map {|t| [t, []] }]
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
    def declare(type, name, *args)
      raise DuplicateDeclarationError if local_declarations.include? name.to_s.to_sym
      case type
      when :variable
        context.build_variable(name, *args).tap do |variable|
          local_variables << variable
        end
      when :constant
        context.build_constant(name, *args).tap do |constant|
          local_constants << constant
        end
      else
        context.build_procedure(name, *args).tap do |procedure|
          local_procedures << procedure
        end
      end
    end
    def retrieve_variable(name)
      retrieve_from_local(name, :variables)
    end
    def retrieve_constant(name)
      retrieve_from_local(name, :constants)
    end
    def retrieve_constant_or_variable(name)
      retrieve_from_local(name, :constants, :variables)
    end
    def retrieve_procedure(name)
      retrieve_from_local(name, :procedures)
    end
    def build_subcontext
      Scope.new(context, self)
    end
  protected
    def retrieve_from_local(name, *types)
      name = name.to_sym
      local = locals(*types).detect {|ident| ident == name }
      wrong_type_local = locals(*(SUPPORTED_TYPES - types)).detect {|ident| ident == name } unless local
      raise WrongTypeDeclarationError.new(wrong_type_local) if wrong_type_local
      parent = @parent.retrieve_from_local(name, *types) if !local && @parent
      local || parent or raise UndeclaredIdentifierError.new
    end
  private
    def locals(*types)
      types.inject([]) {|previous, type| previous + local_declarations_hash[type] }
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