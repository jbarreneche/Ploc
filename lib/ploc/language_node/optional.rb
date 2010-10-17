module Ploc::LanguageNode
  class Optional < Base
    attr_accessor :sequence_nodes
    def initialize(options = {}, &block)
      @block = block
      @options = options
      @sequence = []
      super
    end
    def call_without_callbacks(current, source_code)
      if matches_first?(current)
        call_sequence(current, source_code)
      else
        current
      end
    end
    def matches_first?(token)
      sequence_nodes.first.matches_first?(token)
    end
    def sequence_nodes
      @sequence_nodes ||= @sequence.map do |node_name| 
        fetch_node(node_name)
      end
    end
    def add_node(node)
      @sequence << node
      node
    end
    def inspect
      "<NodeOptional sequence:#{@sequence.inspect} options:#{@options}>"
    end
    def optional?
      true
    end
  private
    def call_sequence(current, remaining)
      sequence_nodes.inject(current) do |current, node|
        node.call(current, remaining)
      end
    end
  end
end