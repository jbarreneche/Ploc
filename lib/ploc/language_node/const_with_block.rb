module Ploc::LanguageNode
  class ConstWithBlock < Base
    attr_accessor :const, :extra
    def initialize(const, options = {}, &block)
      @block = block
      @options = options
      self.const = const
      self.extra = sequence(&block)
    end
    def call(current, remaining)
      last = const_node.call(current, remaining)
      extra_node.call(last,remaining)
    end
    def const_node
      @const_node ||= fetch_node(const)
    end
    def extra_node
      @extra_node ||= fetch_node(extra)
    end
    def inspect
      "<ConstWithBlock const:#{@const.inspect} sequence:#{@extra.inspect}>"
    end
  end
end