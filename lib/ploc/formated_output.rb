module Ploc
  class FormatedOutput < Struct.new(:scanner, :real_output)
    def initialize(scanner, real_output = STDERR)
      super
      @empty = true
      @lines_with_errors = []
    end
    def <<(smtg)
      @empty &&= false
      unless @lines_with_errors.last == scanner.line_number
        real_output << ("%03d #{scanner.current_line}" % scanner.line_number)
        @lines_with_errors << scanner.line_number
      end
      real_output << smtg
      real_output << "\n"
    end
    def empty?
      @empty
    end
  end
end