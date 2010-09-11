module Ploc::LanguageNode
  class ConstWithBlock < Base
    attr_accessor :const, :extra
    def initialize(const, options = {}, &block)
      @block = block
      @options = options
      self.const = const
      @dont_add = true
      self.extra = sequence(&block)
      @dont_add = false
    end
    def language=(language)
      super
      const_node
      extra.language = language
    end
    
    # def add_node(f)
    # end
    def call(current, remaining)
      if const_node.matches_first?(current)
        last = const_node.call(current, remaining)
        @extra.call(last,remaining)
      else
        language.errors << "Expecting specific symbol!: #{const_node.inspect} but found unexpected Symbol (#{current.inspect})" 
        current
      end
    end
    def const_node
      @const_node ||= begin
        cnode = fetch_node(const)
        cnode.language = self.language
        cnode
      end
    end
    def inspect
      "<ConstWithBlock const:#{@const.inspect} sequence:#{@extra.inspect}>"
    end
  end
end