module Ploc::Token
  class Base < Struct.new(:token)
    def self.build(token)
      new(token)
    end
    def to_s
      self.token.to_s
    end
    def ==(o)
      case o
      when ::String
        self.token.casecmp(o) == 0
      when self.class
        self.token.casecmp(o.token) == 0
      else
        super(o)
      end
    end
  end
end