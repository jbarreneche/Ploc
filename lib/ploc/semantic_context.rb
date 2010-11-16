require 'ploc/address'
require 'ploc/constant'
require 'ploc/procedure'
require 'ploc/scope'
require 'ploc/variable'
require "forwardable"

module Ploc
  class SemanticContext
    attr_reader :scope
    attr_accessor :source_code
    extend Forwardable
    def_delegators :@scope, :constants, :variables, :procedures
    def initialize(source_code = nil)
      @source_code = source_code
      # FIXME tests de semantic rules
      @source_code ? @source_code.context=(self) : nil
      @scope = Scope.new(self)
      @var_sequence = -1
    end
    def start_new_scope
      @scope = @scope.build_subcontext
    end
    def close_scope
      @scope = @scope.parent
    end
    def retrieve_constant_or_variable(name)
      @scope.retrieve_constant_or_variable(name)
    rescue Ploc::UndeclaredIdentifierError
      self.source_code.report_error "Undeclared constant or variable #{name}"
      # Declare something just to keep the workflow going on
      declare_variable(name)
    rescue Ploc::WrongTypeDeclarationError
      self.source_code.report_error "Wrong declaration type. Expecting #{name} to be a constant or a variable"
    end
    def retrieve_constant(name)
      @scope.retrieve_constant(name)
    rescue Ploc::UndeclaredIdentifierError
      self.source_code.report_error "Undeclared constant #{name}"
      # Declare something just to keep the workflow going on
      declare_constant(name, 0)
    rescue Ploc::WrongTypeDeclarationError
      self.source_code.report_error "Wrong declaration type. Expecting #{name} to be a constant"
    end
    def retrieve_procedure(name)
      @scope.retrieve_procedure(name)
    rescue Ploc::UndeclaredIdentifierError
      self.source_code.report_error "Undeclared procedure #{name}"
      # Declare something just to keep the workflow going on
      declare_procedure(name, Ploc::Address.new(0))
    rescue Ploc::WrongTypeDeclarationError
      self.source_code.report_error "Wrong declaration type. Expecting #{name} to be a procedure"
    end
    def retrieve_variable(name)
      @scope.retrieve_variable(name)
    rescue Ploc::UndeclaredIdentifierError
      self.source_code.report_error "Undeclared variable #{name}"
      # Declare something just to keep the workflow going on
      declare_variable(name)
    rescue Ploc::WrongTypeDeclarationError
      self.source_code.report_error "Wrong declaration type. Expecting #{name} to be a variable"
    end

    def declare(type, name, *args)
      @scope.declare(type, name, *args)
    rescue Ploc::DuplicateDeclarationError
      self.source_code.report_error "Already declared #{name}"
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
    def source_code_has_errors!
    end
  protected
    def replace_scope(scope)
      @scope = scope
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