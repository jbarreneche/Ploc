module Ploc::LanguageNode
  class Branch < Base
    def initialize(options = {}, &block)
      @options = options
      @branches = []
      super
    end
    def call(current, remaining)
      node = branch_nodes.detect {|node| node.matches_first?(current) }
      if node
        node.call(current, remaining)
      else
        language.errors << "Expecting any of #{branch_nodes.inspect} but found #{current}"
        current
      end
    end
    def matches_first?(token)
      branch_nodes.any?{|node| node.matches_first?(token)}
    end
    def add_node(node)
      @branches << node
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