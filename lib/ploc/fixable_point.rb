module Ploc
  class FixablePoint  < Struct.new(:point_id, :output_to, :size)
    def fix(value)
      output_to.fix_point(self, value)
    end
  end
end