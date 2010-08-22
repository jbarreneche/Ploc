module Ploc
  class Scanner
    def scan(input)
      Enumerator.new do |g|
        while !input.eof? do
          tokens = input.gets.scan /\w+|:=|\S/
          tokens.each {|token| g.yield token }
        end
      end
    end
  end
end