module Ploc::LanguageNode
  class Sequence < Base
    attr_accessor :sequence_nodes
    def initialize(options = {}, &block)
      @block = block
      @options = options
      @sequence = []
      super
    end
    def call(current, remaining)
      last = recursive_call(current, remaining)
      last = call_terminator(last, remaining)
      last
    end
    def separator_node
      @separator_node ||= fetch_node(@options[:separator]) if @options[:separator]
    end
    def terminator_node
      @terminator_node ||= fetch_node(@options[:terminator]) if @options[:terminator]
    end
    def matches_first?(token)
      sequence_nodes.first.matches_first?(token)
    end
    def sequence_nodes
      @sequence_nodes ||= @sequence.map do |node_name| 
        fetch_node(node_name)
      end
    end
    def add_node(node)
      @sequence << node
      node
    end
    def inspect
      "<Node sequence:#{@sequence.inspect} options:#{@options}>"
    end
  private
    def recursive_call(current, remaining)
      last = call_sequence(current, remaining)
      last = call_separator(last, remaining)
    end
    def call_sequence(current, remaining)
      sequence_nodes.inject(current) do |current, node|
        node.call(current, remaining)
      end
    end
    def call_separator(current, remaining)
      if separator_node && separator_node.matches_first?(current)
        last = separator_node.call(current, remaining)
        recursive_call(last,remaining)
      else
        if @options[:repeat] && self.matches_first?(current)
          recursive_call(current,remaining)
        else
          current
        end
      end
    end
    def call_terminator(current, remaining)
      if terminator_node 
        if terminator_node.matches_first?(current)
          terminator_node.call(current, remaining)
        else
          if separator_node
            language.errors << "#{self.inspect} Expecting separator #{separator_node.inspect} or terminator #{terminator_node.inspect} but found #{current.inspect}"
          else
            if matches_first?(current)
              # Recursive call due to not founding terminator and still matches
              recursive_call(current, remaining)
            else
              language.errors << "Expecting terminator #{terminator_node.inspect} but found #{current.inspect}"
            end
          end
        end
      else
        current
      end
    end
    def puts(*args)
      ::Kernel.puts *args
    end
  end
end