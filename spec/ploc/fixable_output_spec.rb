require 'spec_helper'
require 'ploc/fixable_output'
describe Ploc::FixableOutput do
  let(:output_stream) { mock('Output') }
  let(:fixable_point) { mock('FixablePoint') }
  subject { Ploc::FixableOutput.new(output_stream) }
  context 'direct output' do
    it 'redirects recieved outputs to the real output stream' do
      output_stream.should_receive(:<<).with('output')
      subject << 'output'
    end
    it 'redirects successive outputs to the real ouptput stream' do
      output_stream.should_receive(:<<).with('output1').ordered
      output_stream.should_receive(:<<).with('output2').ordered
      subject << 'output1'
      subject << 'output2'
    end
  end
  context 'with one write later' do
    it 'returns a fixable point for the fixable output' do
      Ploc::FixablePoint.should_receive(:new).with(anything, subject, 4) { fixable_point }
      subject.write_later(4).should == fixable_point
    end
    it 'doesnt outputs to output stream if the fixed point isnt fixed' do
      subject.write_later(4)
      output_stream.should_not_receive(:<<)
      subject << 'output'
    end
    describe 'fixing the fixpoint' do
      it 'outputs the fix and pending outputs' do
        fix_point = subject.write_later(4)
        subject << 'output'
        output_stream.should_receive(:<<).with('1234').ordered
        output_stream.should_receive(:<<).with('output').ordered
        fix_point.fix("1234")
      end
    end
    describe 'destroying the fixpoint' do
      it 'outputs pending outputs but not the fixpoint' do
        fix_point = subject.write_later(4)
        subject << 'output'
        output_stream.should_receive(:<<).with('output').ordered
        fix_point.destroy
      end
    end
  end
  context 'with multiple write later' do
    before(:each) do
      @first_fix_point = subject.write_later(4)
      subject << 'output before second fix point'
    end
    it 'doesnt outputs to output stream if the fixed point isnt fixed' do
      new_fix_point = subject.write_later(4)
      output_stream.should_not_receive(:<<)
      new_fix_point.fix('1234')
    end
    it 'outputs everything if all the points are fixed' do
      new_fix_point = subject.write_later(4)
      new_fix_point.fix('1234')
      output_stream.should_receive(:<<).with('5678').ordered
      output_stream.should_receive(:<<).with('output before second fix point').ordered
      output_stream.should_receive(:<<).with('1234').ordered
      @first_fix_point.fix('5678')
    end
  end
end