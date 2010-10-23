module Ploc::LanguageNode
  class Optional < Base
    attr_accessor :sequence_nodes
    def initialize(options = {}, &block)
      @block = block
      @options = options
      @sequence = []
      super
    end
    def call_without_callbacks(source_code)
      if matches_first?(source_code.current_token)
        call_sequence(source_code)
      else
        nil
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
    def call_sequence(source_code)
      sequence_nodes.inject([]) do |sequence_tokens, node|
        sequence_tokens << node.call(source_code)
      end.compact
    end
  end
end