module Ploc
  class BinaryData
    attr_reader :data
    alias :to_s :data
    INT_CONVERSION = 2 ** 32
    def initialize(string)
      @data = string.gsub(/#.*$/,'').split.map {|s| s.to_i(16).chr }.join
    end
    def self.parse_int(int)
      int = int < 0 ? INT_CONVERSION + int : int
      new int.to_s(16).rjust(8, '0').scan(/../).reverse.join(' ')
    end
  end
end