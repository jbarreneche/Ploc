module Ploc
  class BinaryData
    attr_reader :data
    alias :to_s :data
    def initialize(string)
      @data = string.gsub(/#.*$/,'').split.map {|s| s.to_i.chr }.join
    end
  end
end