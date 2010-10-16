module Ploc::LanguageNode
  class ConstWithBlock < Base
    attr_accessor :const, :extra
    def initialize(const, *options, &block)
      super
      @options = *options
      self.const = const
      self.extra = sequence(&block)
    end
    def optional?
      @options.include? :zero_or_one
    end
    def matches_first?(node)
      self.const_node.matches_first?(node)
    end
    def call_without_callbacks(current, remaining)
      if optional? && !const_node.matches_first?(current)
        current
      else
        last = const_node.call(current, remaining)
        extra_node.call(last,remaining)
      end
    end
    def const_node
      @const_node ||= fetch_node(const)
    end
    def extra_node
      @extra_node ||= fetch_node(extra)
    end
    def inspect
      "<ConstWithBlock const:#{@const.inspect} sequence:#{@extra.inspect} optional?:#{optional?}>"
    end
  end
end