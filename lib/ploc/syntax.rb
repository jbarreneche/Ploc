require 'ploc/syntax_builder'
module Ploc
  class Syntax
    attr_accessor :nodes
    def self.build(&block)
      SyntaxBuilder.build(&block)
    end
    def initialize(nodes_hash)
      @nodes = nodes_hash
      @nodes.each do |node_name,node|
        node.language = self
        define_singleton_method node_name do |*attributes, &block|
          node.call(*attributes, &block)
        end
        define_singleton_method "parse_#{node_name}" do |*attributes, &block|
          validate node_name, *attributes, &block
        end
      end
    end
    def before(node, &block)
      @nodes[node].add_before_callback(&block)
    end
    def after(node, &block)
      @nodes[node].add_after_callback(&block)
    end
    def around(node, &block)
      @nodes[node].add_around_callback(&block)
    end
    def after_each(node, &block)
      raise "Not a sequence node!!" unless Ploc::LanguageNode::Sequence === @nodes[node]
      @nodes[node].add_after_each_callback(&block)
    end
    def parse(entry_point, source_code)
      source_code.next_token
      send(entry_point, source_code)
      source_code.errors << "Garbage found #{source_code.current_token.inspect}" if source_code.current_token
      source_code.errors.empty?
    end
    def validate(entry_point, source_code)
      parse(entry_point, source_code)
      source_code.errors
    end
  end
end