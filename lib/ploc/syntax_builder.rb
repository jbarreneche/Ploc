require 'ploc/syntax'
require 'ploc/language_node'

module Ploc
  class SyntaxBuilder < BasicObject
    def self.build(*args, &block)
      new(*args, &block).build
    end
    def initialize(*args, &block)
      ::Kernel.raise 'Block expected' unless block
      @nodes = {}
      instance_eval(&block)
    end
    def terminal(node_name, *args)
      @nodes[node_name] = LanguageNode::Terminal.new(*args)
    end
    def define(node_name, *args, &block)
      @nodes[node_name] = LanguageNode::Sequence.new(*args, &block)
    end
    def method_missing(meth, *args, &block)
      if @nodes.include? meth
        @nodes[meth]
      else
        super
      end
    end
    def build
      Syntax.new(@nodes)
    end
  end
end