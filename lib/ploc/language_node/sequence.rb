module Ploc::LanguageNode
  class Sequence < Base
    def initialize(options = {}, &block)
      @options = options
      @options[:repeat] ||= !!(@options[:separator] || @options[:terminator])
      @sequence = []
      super
    end
    def call(current, remaining)
      last = recursive_call(current, remaining)
      last = call_terminator(last, remaining)
      last
    end
    def matches_first?(token)
      optional? || required_nodes.first.matches_first?(token)
    end
    def add_node(node)
      @sequence << node
      node
    end
    def inspect
      "<Node sequence:#{@sequence.inspect} options:#{@options}>"
    end
    def optional?
      required_nodes.empty?
    end
  private
    def separator_node
      @separator_node ||= fetch_node(@options[:separator]) if @options[:separator]
    end
    def terminator_node
      @terminator_node ||= fetch_node(@options[:terminator]) if @options[:terminator]
    end
    def sequence_nodes
      @sequence_nodes ||= @sequence.map do |node_name| 
        fetch_node(node_name)
      end
    end
    def matches_separator?(token)
      separator_node ? separator_node.matches_first?(token) : starting_nodes.any? {|m| m.matches_first? token }
    end
    def required_nodes
      @required_nodes ||= sequence_nodes.select(&:required?)
    end
    def starting_nodes
      @starting_nodes ||= sequence_nodes.first.required? ? 
        [sequence_nodes.first] : 
        # Starting nodes are the optionals plus the first required
        sequence_nodes.slice_before(&:required?).take(2).flatten
    end
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
      if multiple_sequence? && matches_separator?(current)
        last = (separator_node || Null.new).call(current, remaining)
        recursive_call(last, remaining)
      else
        current
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
            language.errors << "Expecting terminator #{terminator_node.inspect} or #{starting_nodes.inspect} but found #{current.inspect}"
          end
        end
      else
        current
      end
    end
    def multiple_sequence?
      @options[:repeat]
    end
    # def puts(*args)
    #   ::Kernel.puts *args
    # end
  end
end