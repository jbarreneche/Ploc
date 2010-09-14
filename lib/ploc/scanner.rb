require 'ploc/token'

module Ploc
  class Scanner
    attr_reader :line_number, :current_line
    def initialize(input)
      @input = input
      @line_number = 0
      @tokenizer = Enumerator.new do |g|
        while !input.eof? do
          tokens = next_line.scan /\d+|\w+|:=|\S/
          tokens.each {|token| g.yield parse_token(token) }
        end
        g.yield(nil)
      end
    end
    def next
      @tokenizer.next
    end
    def to_a
      @tokenizer.to_a
    end
  private
    def parse_token(token)
      Token.tokenize(token)
    end
    def next_line
      @line_number += 1
      @current_line = @input.gets
    end
  end
end