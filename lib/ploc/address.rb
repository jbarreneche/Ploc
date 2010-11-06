require 'ploc/binary_data'

module Ploc
  class Address
    attr_reader :value
    def initialize(value)
      @value = value
    end
    def -(address_or_value)
      self.class.new(value - extract_value(address_or_value))
    end
    def +(address_or_value)
      self.class.new(value + extract_value(address_or_value))
    end
    def to_bin
      @bin_value ||= BinaryData.new(self.value)
    end
    def ==(o)
      return self.value == o.value if self.class === o
      super
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