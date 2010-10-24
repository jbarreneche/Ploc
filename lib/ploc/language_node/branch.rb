module Ploc::LanguageNode
  class Branch < Base
    def initialize(language, options = {}, &block)
      @options = options
      @branches = []
      super(language, &block)
    end
    def call_without_callbacks(source_code)
      node = branch_nodes.detect {|node| node.matches_first?(source_code.current_token) }
      if node
        node.call(source_code)
      else
        source_code.errors << "Expecting any of #{branch_nodes.inspect} but found #{current.inspect}"
        nil
      end
    end
    def matches_first?(token)
      branch_nodes.any?{|node| node.matches_first?(token)}
    end
    def add_node(name, node)
      @branches << super
      node
    end
    def branch_nodes
      @branch_nodes ||= @branches.map do |node_name| 
        fetch_node(node_name)
      end
    end
    def inspect
      "<branch branches:#{@branches.inspect}>"
    end
  end
end