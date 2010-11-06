module Ploc::LanguageNode
  class Branch < Base
    def initialize(language, options = {}, &block)
      @options = options
      @branches = []
      super(language, &block)
    end
    def call_without_callbacks(source_code)
      node = branch_nodes.detect {|n| n.matches_first?(source_code.current_token) }
      if node
        node.call(source_code)
      else
        report_found_unexpected_token(source_code, "Expecting any of #{branch_nodes.inspect}")
        nil
      end
    end
    def matches_first?(token)
      branch_nodes.any? {|node| node.matches_first?(token)}
    end
    def add_node(name, node)
      @branches << super
      node
    end
    def branch_nodes
      @branch_nodes ||= @branches.map {|node_name| fetch_node(node_name)}
    end
    def inspect
      "<branch branches:#{@branches.inspect}>"
    end
  end
end