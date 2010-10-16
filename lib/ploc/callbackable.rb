module Ploc
  module Callbackable
    def initialize *args
      super
      @before_callbacks = []
      @around_filters = Proc.new {|*args, &block| block.call(*args) }
      @after_callbacks = []
    end
    def add_before_callback(method_name = nil, &new_block)
      new_block ||= method(method_name)
      raise 'no call given' if new_block == nil
      @before_callbacks << new_block
    end
    def add_after_callback(method_name = nil, &new_block)
      new_block ||= method(method_name)
      raise 'no call given' if new_block == nil
      @after_callbacks.unshift(new_block)
    end
    def add_around_callback(method_name = nil, &new_block)
      new_block ||= method(method_name)
      raise 'no call given' if new_block == nil
      old_block = @around_filters
      @around_filters = Proc.new do |*args, &block|
        result = nil
        new_block.call(*args, &Proc.new { result = old_block.call(*args, &block) })
        result
      end
    end
  private
    def _run_callbacks(*args, &block)
      @before_callbacks.each {|bc| bc.call(*args)}
      after = @after_callbacks
      @around_filters.call(*args, &block).tap do |result|
        after.each {|ac| ac.call(result, *args) }
      end
    end
  end
end