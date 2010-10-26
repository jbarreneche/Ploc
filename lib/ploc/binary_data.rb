require 'forwardable'

module Ploc
  class BinaryData
    INT_CONVERSION = 2 ** 32
    class << self
      def parse_string(string)
        string.gsub(/#.*$/,'').split.map {|s| s.to_i(16).chr }.join
      end
      def parse_int(int)
        data = ""
        4.times do 
          int, mod = int.divmod(256)
          data << mod.chr
        end
        data
      end
    end

    attr_reader :data
    alias :to_s :data
    alias :to_str :to_s
    extend Forwardable
    def_delegators :@data, :size
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
    def ==(other)
      return self.to_str == other.to_str if other.respond_to? :to_str
      super
    end
  end
end