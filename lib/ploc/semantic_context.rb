require 'ploc/address'
require 'ploc/constant'
require 'ploc/procedure'
require 'ploc/scope'
require 'ploc/variable'

module Ploc
  class SemanticContext
    attr_reader :scope
    attr_accessor :source_code
    def initialize(source_code = nil)
      @source_code = source_code
      # FIXME tests de semantic rules
      @source_code ? @source_code.context=(self) : nil
      @scope = Scope.new(self)
      @var_sequence = -1
    end
    def retrieve_constant_or_variable(name)
      @scope.retrieve_constant_or_variable(name)
    rescue Ploc::UndeclaredIdentifierError
      self.source_code.errors << "Undeclared constant or variable #{name}"
      # Declare something just to keep the workflow going on
      declare_variable(name)
    end
    def retrieve_constant(name)
      @scope.retrieve_constant(name)
    rescue Ploc::UndeclaredIdentifierError
      self.source_code.errors << "Undeclared constant #{name}"
      # Declare something just to keep the workflow going on
      declare_constant(name, 0)
    end
    def retrieve_variable(name)
      @scope.retrieve_variable(name)
    rescue Ploc::UndeclaredIdentifierError
      self.source_code.errors << "Undeclared variable #{name}"
      # Declare something just to keep the workflow going on
      declare_variable(name)
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
    rescue Ploc::DuplicateDeclarationError
      self.source_code.errors << "Already declared #{name}"
    end
    [:constant, :variable, :procedure].each do |type|
      define_method :"declare_#{type}" do |name, *args|
        declare(type, name, *args)
      end
    end
    def build_variable(name)
      Variable.new name, next_var_address
    end
    def build_constant(name, value)
      Constant.new name, value
    end
    def build_procedure(name, address)
      Procedure.new name, address
    end
  private
    def next_var_address
      Address.new next_var_sequence * 4
    end
    def next_var_sequence
      @var_sequence += 1
    end
  end
end