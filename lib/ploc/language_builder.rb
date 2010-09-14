require 'ploc/language'
require 'ploc/language_node'

module Ploc
  class LanguageBuilder < BasicObject
    def initialize(*args, &block)
      raise 'Block expected' unless block
      @nodes = {}
      instance_eval(&block)
    end
    def terminal(node_name, *args)
      @nodes[node_name] = LanguageNode::Terminal.new(*args)
    end
    def define(node_name, &block)
      @nodes[node_name] = LanguageNode::Sequence.new(&block)
    end
    def method_missing(meth, *args, &block)
      if @nodes.include? meth
        @nodes[meth]
      else
        super
      end
    end
    def build
      Language.new(@nodes)
    end
    def to_s; 'Language Builder'; end
    def inspect; 'Language Builder'; end
  end
end