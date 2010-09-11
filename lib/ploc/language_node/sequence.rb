module Ploc::LanguageNode
  class Sequence < Base
    attr_accessor :sequence_nodes
    def initialize(options = {}, &block)
      @block = block
      @options = options
      @sequence = []
      @lock = false
      instance_eval(&block) if block
      @lock = true
    end
    def call(current, remaining)
      last = sequence_nodes.inject(current) do |current, node|
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
        fetch_node(node_name)
      end
    end
    def add_node(node)
      @sequence << node
    end
    def sequence(*args, &block)
      @dont_add = true
      super
      @dont_add = false
    end
    def fetch_node(node_name)
      if Base === node_name
        node_name.language = self.language
        node_name
      else
        @language.nodes[node_name]
      end
    end
    def method_missing(meth, *args)
      unless @lock
        add_node(meth) unless @dont_add
        meth
      else
        super
      end
    end
    def inspect
      "<Node sequence:#{@sequence.inspect} options:#{@options}>"
    end
  end
end