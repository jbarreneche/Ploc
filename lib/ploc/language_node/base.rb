module Ploc::LanguageNode
  class Base < BasicObject
    attr_accessor :language
    def sequence(*params, &block)
      add_node(Sequence.new(*params, &block))
    end
    def branch(*params, &block)
      Branch.new(*params, &block)
    end
  end
end