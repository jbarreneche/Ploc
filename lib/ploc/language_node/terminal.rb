require 'ploc/token_matcher'

module Ploc::LanguageNode
  class Terminal < Base
    attr_reader :matcher
    def initialize(matcher, *symbols)
      @matcher = ::Ploc::TokenMatcher.new(matcher, *symbols)
      super
    end
    def call_without_callbacks(current, remaining)
      if matches_first?(current)
        remaining.next
      else
        language.errors << "Expecting: #{self.matcher.inspect} but found unexpected Symbol (#{current.inspect})" 
        current
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