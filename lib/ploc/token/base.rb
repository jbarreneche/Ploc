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
      when String
        self.to_s == o
      when self.class
        self.token == o.token
      else
        super(o)
      end
    end
  end
end