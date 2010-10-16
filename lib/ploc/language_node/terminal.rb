require 'ploc/token_matcher'
module Ploc::LanguageNode
  class Terminal < Base
    attr_reader :matcher
    def initialize(matcher, *symbols)
      super
      @matcher = ::Ploc::TokenMatcher.new(matcher, *symbols)
    end
    def call_without_callbacks(current, remaining)
      if matches_first?(current)
        remaining.next
      else
        language.errors << "Expecting: #{@matcher.inspect} but found unexpected Symbol (#{current.inspect})" 
        current
      end
    end
    def matches_first?(token)
      @matcher.matches?(token)
    end
    def inspect
      "<Node terminal:#{@matcher.inspect} #{@symbols ? @symbols.inspect : ''}>"
    end
  end
end