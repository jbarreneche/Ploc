require 'spec_helper'
require 'ploc/fixable_point'

describe Ploc::FixablePoint do
  let(:output) { mock('Output') }
  subject { Ploc::FixablePoint.new(:id, output, 4) }
  describe '#fix' do
    it 'notifies to its output when its fixed' do
      output.should_receive(:fix_point).with(subject, '1234')
      subject.fix('1234')
    end
  end
end