require 'ploc/callbackable'

module Ploc::LanguageNode
  class Base < BasicObject
    attr_reader :language
    include ::Ploc::Callbackable

    def initialize(language, &block)
      ::Kernel.raise "Must provide a language" unless language
      @language = language
      super()
      instance_eval(&block) if block
      @initialization_finished = true
    end
    def optional(options = {}, &block)
      add_node(options.delete(:name), Optional.new(self.language, options, &block))
    end
    def sequence(options = {}, &block)
      add_node(options.delete(:name), Sequence.new(self.language, options, &block))
    end
    def branch(options = {}, &block)
      add_node(options.delete(:name), Branch.new(self.language, options, &block))
    end
    def fetch_node(node_name)
      node = ::Symbol === node_name ? @language.nodes[node_name] : node_name
      ::Kernel.raise "Node not found #{node_name}" unless node
      node
    end
    def call_with_callbacks(source_code)
      _run_callbacks(source_code) { self.call_without_callbacks(source_code) }
    end
    alias :call :call_with_callbacks
    # Subclasses should override if they want to have the nodes used
    def add_node(name, node)
      language.nodes[name] = node if name
      node
    end
    def optional?
      false
    end
    def required?
      !optional?
    end
  private
    def method_missing(meth, options = {}, &block)
      unless @initialization_finished
        add_node(nil, meth)
      else
        super
      end
    end
    # def puts(*args)
    #   ::Kernel.puts *args
    # end
  end
end