require 'ploc/token_matcher'

module Ploc::LanguageNode
  class Terminal < Base
    attr_reader :matcher
    def initialize(matcher, *symbols)
      @matcher = ::Ploc::TokenMatcher.new(matcher, *symbols)
      super
    end
    def call_without_callbacks(source_code)
      if matches_first?(source_code.current_token)
        current = source_code.current_token
        source_code.next_token
        current
      else
        source_code.errors << "Expecting: #{self.matcher.inspect} but found unexpected Symbol (#{source_code.current_token.inspect})" 
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