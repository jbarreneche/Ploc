require 'ploc/token_matcher'

module Ploc::LanguageNode
  class Terminal < Base
    attr_reader :matcher, :language_extensions
    def initialize(language, matcher, *symbols, &block)
      @matcher = ::Ploc::TokenMatcher.new(matcher, *symbols)
      @language_extensions = []
      super(language, &block)
    end
    def call_without_callbacks(source_code)
      if matches_first?(source_code.current_token)
        current = source_code.current_token
        source_code.next_token
        current
      else
        report_found_unexpected_token(source_code, "Expecting #{self.matcher.inspect}")
        source_code.next_token if language_extensions.any? {|le| le.matches?(source_code.current_token) }
      end
    end
    def matches_first?(token)
      self.matcher.matches?(token)
    end
    def inspect
      "<Node terminal:#{self.matcher.inspect}>"
    end
    def extend_to(matcher, *symbols)
      @language_extensions << ::Ploc::TokenMatcher.new(matcher, *symbols)
    end
  end
end