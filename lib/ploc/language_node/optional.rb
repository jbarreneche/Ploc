require 'ploc/language_node/sequence'
require 'forwardable'

module Ploc::LanguageNode
  class Optional < Base
    extend ::Forwardable
    def_delegators :@sequence, :add_after_each_callback, :matches_first?, :matcher_inspect
    def initialize(language, options = {}, &block)
      super(language) {}
      @sequence = Sequence.new(language, options, &block)
    end
    def call_without_callbacks(source_code)
      @sequence.call(source_code) if matches_first?(source_code.current_token)
    end
    def optional?
      true
    end
    def inspect
      "<NodeOptional sequence:#{@sequence.inspect}>"
    end
  end
end