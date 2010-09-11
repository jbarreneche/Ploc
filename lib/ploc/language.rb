require 'ploc/language_builder'
module Ploc
  class Language
    attr_accessor :nodes
    attr_accessor :errors
    def self.build(&block)
      LanguageBuilder.new(&block).build
    end
    def initialize(nodes_hash)
      @nodes = nodes_hash
      nodes_hash.each do |node_name,node|
        node.language = self
        define_singleton_method node_name do |*attributes, &block|
          node.call(*attributes, &block)
        end
      end
    end
    def validate(entry_point, tokens)
      @errors = []
      last_token = send entry_point, tokens.next, tokens
      @errors << "Garbage found #{last_token.inspect}" if last_token
      @errors
    end
  end
end