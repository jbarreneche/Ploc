require 'spec_helper'
require 'ploc/language_node'
require 'ploc/source_code'

module Ploc::LanguageNode
  describe Sequence do
    def input_sequence(array)
      Ploc::SourceCode.new(array.push(nil).enum_for).tap do |sc|
        sc.next_token
      end
    end
    before(:each) do
      @language = Object.new
      @term = Terminal.new @language, String, 't'
      @sep  = Terminal.new @language, String, 's'
      @smtg = Terminal.new @language, String, *(0..9).map(&:to_s)
      @language.stub('nodes').and_return(term: @term, smtg: @smtg, sep: @sep)
    end
    context 'with a terminator' do
      subject { Sequence.new(@language, terminator: :term) { smtg } }

      it 'repeats correctly until terminator' do
        source_code = input_sequence(%w[1 2 3 4 5 6 7 8 9 t])
        source_code.should_not_receive(:errors)
        subject.call(source_code).should == %w[1 2 3 4 5 6 7 8 9]
      end
    end
    context 'with a separator' do
      subject { Sequence.new(@language, separator: :sep) { smtg }}

      it 'repeats the sequence while there are separators' do
        source_code = input_sequence(%w[1 s 1 s 1 s 1 s 1 s 1 s 1 s 1 s 1])
        source_code.should_not_receive(:errors)
        subject.call(source_code).should == %w[1 1 1 1 1 1 1 1 1]
      end
      describe 'Weak separators' do
        before(:each) do
          subject.separator_is_weak!
        end
        it 'continues sequence no matter if they are missing' do
          source_code = input_sequence(%w[1 s 1 1 s 1 s 1 s 1 s 1 s 1 s 1])
          errors = mock('Errors').as_null_object
          source_code.stub(:errors) { errors }
          subject.call(source_code).should == %w[1 1 1 1 1 1 1 1 1]
        end
        it 'register missing separator error' do
          source_code = input_sequence(%w[1 s 1 1 s 1 s 1 s 1 s 1 s 1 s 1])
          errors = mock('Errors')
          source_code.stub(:errors) { errors }
          errors.should_receive :<<
          subject.call(source_code).should == %w[1 1 1 1 1 1 1 1 1]
        end
      end
    end
    context 'with a separator' do
      subject { Sequence.new(@language, separator: :sep, terminator: :term) { smtg }}

      it 'repeats correctly while separator until terminator' do
        source_code = input_sequence(%w[1 s 1 s 1 s 1 s 1 s 1 s 1 s 1 s 1 t])
        source_code.should_not_receive(:errors)
        subject.call(source_code).should == %w[1 1 1 1 1 1 1 1 1]
      end
    end
    context 'with repeat param' do
      subject { Sequence.new(@language, repeat: true) { smtg }}

      it 'repeats correctly while separator until terminator' do
        source_code = input_sequence(%w[1 1 1 1 1 1 1 1 1])
        source_code.should_not_receive(:errors)
        subject.call(source_code).should == %w[1 1 1 1 1 1 1 1 1]
      end
    end
  end
end
