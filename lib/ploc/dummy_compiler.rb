require 'ploc/compiler'
module Ploc
  class DummyCompiler < Compiler
    def method_missing(*args)
      # Discar unknown messages
    end
  end
end