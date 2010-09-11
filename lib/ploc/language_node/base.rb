module Ploc::LanguageNode
  class Base < BasicObject
    attr_accessor :language
    def initialize(*args, &block)
      @lock = false
      instance_eval(&block) if block
      @lock = true
    end
    def sequence(*params, &block)
      seq = Sequence.new(*params, &block)
      add_node(seq)
      seq
    end
    def branch(*params, &block)
      Branch.new(*params, &block)
    end
    def fetch_node(node_name)
      if Base === node_name
        node_name.language = self.language
        node_name
      else
        @language.nodes[node_name]
      end
    end
    def method_missing(meth, *args, &block)
      unless @lock
        node = block ? ConstWithBlock.new(meth, *args, &block) : meth 
        add_node(node) unless @dont_add
        node
      else
        super
      end
    end
    def inspect
      "Inspecting ..."
    end
  end
end