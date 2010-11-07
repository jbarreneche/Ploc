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
        real_output << for_output
      end
    end
    def write_later(size)
      Ploc::FixablePoint.new(next_fix_id, self, size).tap {|fp| pending_outputs << fp }
    end
    def any_fix_pending?
      !pending_outputs.empty?
    end
    def fix_point(fixable_point, value)
      idx = pending_outputs.index(fixable_point)
      pending_outputs[idx] = value
      flush_pending_outputs
    end
    def remove_fixpoint(fixable_point)
      pending_outputs.delete(fixable_point)
      flush_pending_outputs
    end
    def empty?
      size == 0
    end
    def size
      real_output.size + (pending_outputs.map(&:size).reduce(&:+) || 0)
    end
    def close
      real_output.close
    end
  private
    def flush_pending_outputs
      @pending_outputs = pending_outputs.drop_while do |out|
        real_output << out unless Ploc::FixablePoint === out
        !out.is_a? Ploc::FixablePoint
      end
    end
    def pending_outputs
      @pending_outputs
    end
    def next_fix_id
      @fix_point_number += 1
    end
  end
end