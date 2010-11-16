module Ploc
  class SourceCode < Struct.new(:scanner)

    attr_reader :current_token
    attr_reader :errors
    attr_accessor :context

    def initialize(scanner, *args)
      super(scanner)
      @errors = args.shift || []
    end
    
    def next_token
      @current_token = scanner.next
    end
    def report_error(something)
      context.source_code_has_errors! if self.errors.empty? && context
      @errors << something
    end
  end
end