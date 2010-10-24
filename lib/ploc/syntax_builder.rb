require 'ploc/syntax'
require 'ploc/language_node'

module Ploc
  class SyntaxBuilder < BasicObject
    def self.build(language, *args, &block)
      new(language, *args, &block).build
    end
    def initialize(language, *args, &block)
      ::Kernel.raise 'Block expected' unless block
      @language = language
      instance_eval(&block)
    end
    def terminal(node_name, *args)
      @language.nodes[node_name] = LanguageNode::Terminal.new(@language, *args)
    end
    def define(node_name, *args, &block)
      @language.nodes[node_name] = LanguageNode::Sequence.new(@language, *args, &block)
    end
    def method_missing(meth, *args, &block)
      if @language.nodes.include? meth
        @language.nodes[meth]
      else
        super
      end
    end
    def build
      @language.build_nodes
      @language
    end
  end
end