require 'ploc/dummy_compiler'

module Ploc
  class Language
    attr_accessor :parser, :scanner_builder, :compiler_builder

    def initialize(attrs = {})
      self.parser ||= attrs[:parser]
      self.scanner_builder ||= attrs[:scanner_builder]
      self.compiler_builder ||= attrs[:compiler_builder]
    end
    def compile(program)
      new_compiler(scan(program)).tap do |compiler|
        self.parser.parse :program, compiler
      end
    end
    def parse(program)
      new_dummy_compiler(scan(program)).tap do |compiler|
        self.parser.parse :program, compiler
      end.errors
    end
    def scan(program)
      self.scanner_builder.call(program)
    end

  private
    def new_compiler(scanner)
      self.compiler_builder.call(scanner)
    end
    def new_dummy_compiler(scanner)
      Ploc::DummyCompiler.new(scanner)
    end
  end
end