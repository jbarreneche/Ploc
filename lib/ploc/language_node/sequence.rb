module Ploc::LanguageNode
  class Sequence < Base
    attr_accessor :sequence_nodes
    def initialize(options = {}, &block)
      @block = block
      @options = options
      @sequence = []
      super
    end
    def call(current, remaining)
      last = sequence_nodes.inject(current) do |current, node|
        node.language = self.language
        node.call(current, remaining)
      end
      if @options[:separator] && separator_node.matches_first?(last)
        last = separator_node.call(last, remaining)
        last = self.call(last,remaining)
      end
      last
    end
    def separator_node
      @separator_node ||= fetch_node(@options[:separator])
    end
    def matches_first?(token)
      sequence_nodes.first.matches_first?(token)
    end
    def sequence_nodes
      @sequence_nodes ||= @sequence.map do |node_name| 
        node = fetch_node(node_name)
        node.language = self.language
        node
      end
    end
    def add_node(node)
      @sequence << node
    end
    def language=(language)
      super
      sequence_nodes
    end
    def sequence(*args, &block)
      @dont_add = true
      super
      @dont_add = false
    end
    def inspect
      "<Node sequence:#{@sequence.inspect} options:#{@options} language:#{language.inspect}>"
    end
  end
end