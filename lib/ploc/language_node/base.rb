module Ploc::LanguageNode
  class Base < BasicObject
    attr_accessor :language
    def initialize(*args, &block)
      instance_eval(&block) if block
      @initialization_finished = true
    end
    def optional(*params, &block)
      add_node(Optional.new(*params, &block))
    end
    def sequence(*params, &block)
      add_node(Sequence.new(*params, &block))
    end
    def branch(*params, &block)
      add_node(Branch.new(*params, &block))
    end
    def fetch_node(node_name)
      node = ::Symbol === node_name ? @language.nodes[node_name] : node_name
      ::Kernel.raise "Node not found #{node_name}" unless node
      node.language = self.language
      node
    end
    
    # Subclasses should override if they want to have the nodes used
    def add_node(node)
      node
    end
    def optional?
      false
    end
    def required?
      !optional?
    end
    def method_missing(meth, *args, &block)
      unless @initialization_finished
        node = block ? ConstWithBlock.new(meth, *args, &block) : meth 
        add_node(node)
      else
        super
      end
    end
    # def puts(*args)
    #   ::Kernel.puts *args
    # end
  end
end