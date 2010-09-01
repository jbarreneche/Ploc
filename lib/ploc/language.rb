module Ploc
  class Language
    attr_accessor :nodes
    attr_accessor :errors
    def initialize(nodes_hash)
      @nodes = nodes_hash
      nodes_hash.each do |(node_name,node)|
        node.language = self
        define_singleton_method node_name do |*attributes, &block|
          node.call(*attributes, &block)
        end
      end
    end
    def validate(entry_point, tokens)
      @errors = []
      last_token = send entry_point, tokens.next, tokens
      @errors << 'Garbage found' if last_token
      @errors
    end
  end
end