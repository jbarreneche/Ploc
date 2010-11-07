module Ploc
  class FixablePoint  < Struct.new(:point_id, :output_to, :size)
    def fix(value)
      output_to.fix_point(self, value)
    end
    def destroy
      output_to.remove_fixpoint(self)
    end
  end
end