require 'stringio'
require 'ploc/source_code'
require 'ploc/validation_context'

module Ploc
  class Language
    attr_accessor :parser, :scanner_builder, :context_builder

    def initialize(attrs = {})
      self.parser ||= attrs[:parser]
      self.scanner_builder ||= attrs[:scanner_builder]
      self.context_builder ||= attrs[:context_builder]
    end
    def compile(program, output = StringIO.new)
      new_compiling_context(program, output).tap do |compiler|
        self.parser.parse :program, compiler.source_code
      end
    end
    def parse(program)
      new_validation_context(program).tap do |compiler|
        self.parser.parse :program, compiler.source_code
      end.errors
    end
    def scan(program)
      self.scanner_builder.call(program)
    end

  private
    def new_compiling_context(program, output)
      self.context_builder.call(new_source_code(program), output)
    end
    def new_validation_context(program)
      ValidationContext.new(new_source_code(program))
    end
    def new_source_code(program)
      SourceCode.new(scan(program))
    end
  end
end