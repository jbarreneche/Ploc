module Ploc
  class BinaryData
    attr_reader :data
    alias :to_s :data
    INT_CONVERSION = 2 ** 32
    def initialize(*values)
      @data = values.map do |value|
        case value
        when String
          self.class.parse_string(value)
        when Fixnum
          self.class.parse_int(value)
        else
          ""
        end
      end.join
    end
    def self.parse_string(string)
      string.gsub(/#.*$/,'').split.map {|s| s.to_i(16).chr }.join
    end
    def self.parse_int(int)
      data = ""
      4.times do 
        int, mod = int.divmod(256)
        data << mod.chr
      end
      data
    end
  end
end