require 'ploc/fixable_point'
module Ploc
  class FixableOutput < Struct.new(:real_output)
    def initialize(real_output)
      super
      @pending_outputs = []
      @fix_point_number = 0
    end
    def <<(for_output)
      if any_fix_pending?
        pending_outputs << for_output
      else
        self.real_output << for_output
      end
    end
    def write_later(size)
      @any_fix_pending = true
      Ploc::FixablePoint.new(next_fix_id, self, size).tap {|fp| pending_outputs << fp }
    end
    def any_fix_pending?
      !pending_outputs.empty?
    end
    def fix_point(fixable_point, value)
      @any_fix_pending = false
      idx = pending_outputs.index(fixable_point)
      pending_outputs[idx] = value
      pending_outputs.drop_while do |value|
        self.real_output << value unless Ploc::FixablePoint === value
        !value.is_a? Ploc::FixablePoint
      end
    end
  private
    def pending_outputs
      @pending_outputs
    end
    def next_fix_id
      @fix_point_number += 1
    end
  end
end