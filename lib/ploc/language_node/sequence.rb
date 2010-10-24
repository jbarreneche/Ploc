module Ploc::LanguageNode
  class Sequence < Base
    def initialize(language, options = {}, &block)
      @options = options
      @options[:repeat] ||= !!(@options[:separator] || @options[:terminator])
      @sequence = []
      @after_each_callbacks = []
      super(language, &block)
    end
    def call_without_callbacks(source_code)
      transversed_tokens = recursive_call(source_code)
      call_terminator(source_code)
      transversed_tokens
    end
    def matches_first?(token)
      optional? || required_nodes.first.matches_first?(token)
    end
    def add_node(name, node)
      @sequence << super
      node
    end
    def inspect
      "<Node sequence:#{@sequence.inspect} options:#{@options}>"
    end
    def optional?
      required_nodes.empty?
    end
    def add_after_each_callback(&block)
      @after_each_callbacks << block
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
    def recursive_call(source_code, transversed_tokens = [])
      new_sequence_tokens = call_sequence(source_code)
      separate_and_repeat(source_code, transversed_tokens.concat(new_sequence_tokens))
    end
    def call_sequence(source_code)
      _run_sequence_callbacks(source_code) do |source_code|
        sequence_nodes.inject([]) do |sequence_tokens, node|
          sequence_tokens << node.call(source_code)
        end.compact
      end
    end
    def separate_and_repeat(source_code, transversed_tokens)
      if multiple_sequence? && matches_separator?(source_code.current_token)
        separator_node.call(source_code) if separator_node
        recursive_call(source_code, transversed_tokens)
      else
        transversed_tokens
      end
    end
    def call_terminator(source_code)
      last_node = terminator_node || Null.new(self.language)
      if last_node.matches_first?(source_code.current_token)
        last_node.call(source_code)
      else
        report_invalid_sequence_ending(source_code)
        nil
      end
    end
    def report_invalid_sequence_ending(source_code)
      case
      when separator_node && terminator_node
        source_code.errors << "Expecting separator #{separator_node.inspect} or terminator #{terminator_node.inspect} but found #{source_code.current_token.inspect}"
      when separator_node
        source_code.errors << "Expecting separator #{separator_node.inspect} but found #{source_code.current_token.inspect}"
      when terminator_node
        source_code.errors << "Expecting terminator #{terminator_node.inspect} or #{starting_nodes.inspect} but found #{source_code.current_token.inspect}"
      else
        nil
      end
    end
    def multiple_sequence?
      @options[:repeat]
    end
    def _run_sequence_callbacks(*args, &block)
      block.call(*args).tap do |result|
        @after_each_callbacks.each {|cb| cb.call(result, *args)}
      end
    end
    # def puts(*args)
    #   ::Kernel.puts *args
    # end
  end
end