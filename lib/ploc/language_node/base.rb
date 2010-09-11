module Ploc::LanguageNode
  class Base < BasicObject
    attr_accessor :language
    def initialize(*args, &block)
      instance_eval(&block) if block
      @initialization_finished = true
    end
    def sequence(*params, &block)
      add_node(Sequence.new(*params, &block))
    end
    def branch(*params, &block)
      add_node(Branch.new(*params, &block))
    end
    def fetch_node(node_name)
      node = Base === node_name ? node_name : @language.nodes[node_name]
      node.language = self.language
      node
    end
    
    # Subclasses should override if they want to have the nodes used
    def add_node(node)
      node
    end
    def method_missing(meth, *args, &block)
      unless @initialization_finished
        node = block ? ConstWithBlock.new(meth, *args, &block) : meth 
        add_node(node)
        node
      else
        super
      end
    end
  end
end