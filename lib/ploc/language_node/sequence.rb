module Ploc::LanguageNode
  class Sequence < Base
    attr_accessor :sequence_nodes
    def initialize(&block)
      @block = block
      @sequence = []
      @lock = false
      instance_eval(&block)
      @lock = true
    end
    def call(current, remaining)
      sequence_nodes.inject(current) do |current, node|
        node.call(current, remaining)
      end
    end
    def sequence_nodes
      @sequence_nodes ||= @sequence.map {|node_name| @language.nodes[node_name] }
    end
    def method_missing(meth, *args)
      unless @lock
        @sequence << meth
      else
        super
      end
    end
  end
end