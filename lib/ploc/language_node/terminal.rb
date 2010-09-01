module Ploc::LanguageNode
  class Terminal < Base
    attr_reader :matcher
    def initialize(matcher)
      @matcher = matcher
    end
    def call(current, remaining)
      if matcher === current
        remaining.next
      else
        language.errors << 'Unexpected Symbol' 
        current
      end
    end
  end
end