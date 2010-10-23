# encoding: utf-8
require 'ploc/semantic_context'
require 'ploc/binary_data'
module Ploc::PL0
  class CompilingContext < Ploc::SemanticContext
    attr_reader :output
    def initialize(source_code = nil)
      super(source_code)
      @output = []
    end
    def initialize_new_program!(*args)
      self.output << Ploc::BinaryData.new(File.read('support/elf_header'))
    end
    def complete_program(*args)
    end
  end
end