module Ploc::LanguageNode
  class Terminal < Base
    attr_reader :matcher
    def initialize(matcher, *symbols)
      @matcher = matcher
      @symbols = symbols.empty? ? false : symbols
    end
    def call(current, remaining)
      if matches_first?(current)
        remaining.next
      else
        language.errors << "Expecting: #{@matcher.inspect} but found unexpected Symbol (#{current.inspect})" 
        current
      end
    end
    def matches_first?(token)
      matcher === token && (!@symbols || @symbols.include?(token.to_s))
    end
    def inspect
      "<Node terminal:#{@matcher.inspect}>"
    end
  end
end