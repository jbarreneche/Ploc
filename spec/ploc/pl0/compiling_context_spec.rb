require 'spec_helper'
require 'ploc/pl0/compiling_context'

module Ploc::PL0
  describe CompilingContext do
    its(:output) { should be_empty }
    it 'should output header when initializing new program' do
      pending('still not sure about how to implement fixups...')
    end
  end
end