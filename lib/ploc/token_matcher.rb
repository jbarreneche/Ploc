module Ploc
  class TokenMatcher
    def initialize(klass, *symbols)
      @class = klass
      @symbols = symbols.empty? ? false : symbols
    end
    def matches?(token)
      @class === token && (!@symbols || @symbols.include?(token.to_s))
    end
    def inspect
      @inspection ||= begin
        syms = @symbols || ['*']
        "#{@class}(#{syms.join(', ')})"
      end
    end
  end
end