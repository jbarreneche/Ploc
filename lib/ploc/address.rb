require 'ploc/binary_data'

module Ploc
  class Address
    attr_reader :value
    def initialize(value)
      @value = value
    end
    def -(address)
      self.class.new(value - address.value)
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