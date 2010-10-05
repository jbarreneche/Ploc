module Ploc::LanguageNode
  class Null < Base
    def call(current, remaining)
      current
    end
    def matches_first?(token)
      true
    end
    def inspect
      "Dddddddd"
    end
  end
end