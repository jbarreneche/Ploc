require 'ploc/dummy_compiler'

module Ploc
  class Language
    attr_accessor :parser
    attr_accessor :scanner_builder
    attr_accessor :compiler_builder
    def compile program
      new_compiler(scan(program)).tap do |compiler|
        self.parser.parse :program, compiler
      end
    end
    def parse program
      compiler = new_dummy_compiler(scan(program))
      self.parser.parse :program, compiler
      compiler.errors
    end
    def scan program
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