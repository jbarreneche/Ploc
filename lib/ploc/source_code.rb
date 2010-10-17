module Ploc
  class SourceCode < Struct.new(:scanner)

    attr_reader :current_token
    attr_reader :errors
    attr_accessor :compiling_context

    def initialize(*args)
      super
      @errors = []
    end
    
    def next_token
      @current_token =  scanner.next
    end
  end
end