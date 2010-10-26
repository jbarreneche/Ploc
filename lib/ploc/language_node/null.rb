module Ploc::LanguageNode
  class Null < Base
    def call_without_callbacks(source_code)
      nil
    end
    def matches_first?(token)
      true
    end
    def optional?
      true
    end
    def inspect
      "<NullNode>"
    end
  end
end