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
  describe '#destroy' do
    it 'notifies its output to remove him from the stream' do
      output.should_receive(:remove_fixpoint).with(subject)
      subject.destroy
    end
  end
end