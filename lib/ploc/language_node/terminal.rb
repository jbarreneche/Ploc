require 'ploc/token_matcher'

module Ploc::LanguageNode
  class Terminal < Base
    attr_reader :matcher
    def initialize(language, matcher, *symbols, &block)
      @matcher = ::Ploc::TokenMatcher.new(matcher, *symbols)
      super(language, &block)
    end
    def call_without_callbacks(source_code)
      if matches_first?(source_code.current_token)
        current = source_code.current_token
        source_code.next_token
        current
      else
        report_found_unexpected_token(source_code, "Expecting #{self.matcher.inspect}")
        nil
      end
    end
    def matches_first?(token)
      self.matcher.matches?(token)
    end
    def inspect
      "<Node terminal:#{self.matcher.inspect}>"
    end
  end
end