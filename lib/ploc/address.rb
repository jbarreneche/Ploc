module Ploc
  class Address
    attr_reader :value
    alias :to_i :value
    def initialize(value)
      @value = value
    end
    def -(address_or_value)
      self.class.new(value - extract_value(address_or_value))
    end
    def +(address_or_value)
      self.class.new(value + extract_value(address_or_value))
    end
    def ==(o)
      case o
      when self.class
        self.value == o.value
      when Fixnum
        self.value == o
      else
        super
      end
    end
    def to_s
      self.value.to_s(16)
    end
  private
    def extract_value(address_or_value)
      self.class === address_or_value ? address_or_value.value : address_or_value
    end
  end
end