require 'ploc/binary_data'

module Ploc
  class Address
    attr_reader :value
    def initialize(value)
      @value = value
    end
    def -(address)
      other_value = self.class === address ? address.value : address
      self.class.new(value - other_value)
    end
    def +(address)
      other_value = self.class === address ? address.value : address
      self.class.new(value + other_value)
    end
    def to_bin
      @bin_value ||= BinaryData.new(self.value).to_s
    end
    def ==(o)
      return self.value == o.value if self.class === o
      super
    end
  end
end