require 'ploc/semantic_context'

module Ploc
  class ValidationContext < SemanticContext
    def method_missing(*args, &block)
      # Discard any other message
    end
  end
end