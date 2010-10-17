require 'ploc/token'
require 'forwardable'

module Ploc
  class Scanner
    extend Forwardable

    attr_reader :line_number, :current_line
    def_delegators :@tokenizer, :next, :to_a

    def initialize(input, regex)
      @input = input
      @line_number = 0
      @tokenizer = Enumerator.new do |g|
        while !input.eof? do
          tokens = next_line.scan(regex)
          tokens.each {|token| g.yield Token.tokenize(token) }
        end
        g.yield(nil)
      end
    end

  private
    def next_line
      @line_number += 1
      @current_line = @input.gets
    end
  end
end