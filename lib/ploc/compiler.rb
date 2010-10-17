module Ploc
  class Compiler < Struct.new(:scanner, :context)

    attr_reader :current_token
    attr_reader :errors
    def initialize(*args)
      super
      @errors = []
    end
    
    def next_token
      @current_token =  scanner.next
    end
    alias :next :next_token
  end
end