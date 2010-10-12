module Ploc
  class BinaryData
    def initialize(string)
      @data = string.gsub(/#.*$/,'').split.map {|s| s.to_i.chr }.join
    end
    def to_s
      @data
    end
  end
end