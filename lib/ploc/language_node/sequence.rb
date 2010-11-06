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
      starting_nodes.any? {|node| node.matches_first?(token)}
    end
    def add_node(name, node)
      @sequence << super
      node
    end
    def optional?
      !sequence_nodes.any?(&:required?)
    end
    def add_after_each_callback(&block)
      @after_each_callbacks << block
    end
    def inspect
      "<Node sequence:#{@sequence.inspect} options:#{@options.inspect}>"
    end
  private
    def separator_node
      @separator_node ||= fetch_node(@options[:separator]) if @options[:separator]
    end
    def terminator_node
      @terminator_node ||= fetch_node(@options[:terminator]) if @options[:terminator]
    end
    def sequence_nodes
      @sequence_nodes ||= @sequence.map {|node_name| fetch_node(node_name) }
    end
    def matches_separator?(token)
      separator_node ? separator_node.matches_first?(token) : starting_nodes.any? {|m| m.matches_first? token }
    end
    def starting_nodes
      @starting_nodes ||= begin
        optionals = sequence_nodes.take_while(&:optional?)
        first_required = sequence_nodes.size > optionals.size ? [sequence_nodes[optionals.size]] : []
        optionals + first_required
      end
    end
    def recursive_call(source_code, transversed_tokens = [])
      new_sequence_tokens = call_sequence(source_code)
      separate_and_repeat(source_code, transversed_tokens.concat(new_sequence_tokens))
    end
    def call_sequence(sc)
      _run_sequence_callbacks(sc) do |source_code|
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
        report_found_unexpected_token(source_code, "Expecting separator #{separator_node.inspect} or terminator #{terminator_node.inspect}")
      when separator_node
        report_found_unexpected_token(source_code, "Expecting separator #{separator_node.inspect}")
      when terminator_node
        report_found_unexpected_token(source_code, "Expecting terminator #{terminator_node.inspect} or #{starting_nodes.inspect}")
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