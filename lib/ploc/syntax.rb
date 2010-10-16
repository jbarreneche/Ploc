require 'ploc/syntax_builder'
module Ploc
  class Syntax
    attr_accessor :nodes, :errors
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
    def parse(entry_point, compiler)
      send(entry_point, compiler.next_token, compiler)
    end
    def validate(entry_point, tokens)
      @errors = []
      last_token = send(entry_point, tokens.next, tokens)
      @errors << "Garbage found #{last_token.inspect}" if last_token
      @errors
    end
  end
end