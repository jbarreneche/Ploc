require 'ploc/token'

module Ploc
  class Scanner
    attr_reader :line_number, :current_line
    def initialize(input)
      @input = input
      @line_number = 0
      string_regex = lambda {|sep| "#{sep}[^#{sep}]*#{sep}|#{sep}[^#{sep}]*$"}
      regex = /#{string_regex["'"]}|#{string_regex['"']}|\d+|\w+|:=|\S/
      @tokenizer = Enumerator.new do |g|
        while !input.eof? do
          tokens = next_line.scan(regex)
          tokens.each {|token| g.yield Token.tokenize(token) }
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
    def next_line
      @line_number += 1
      @current_line = @input.gets
    end
  end
end