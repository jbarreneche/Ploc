require 'spec_helper'
require 'ploc/language_node'
require 'ploc/source_code'

module Ploc::LanguageNode
  describe Sequence do
    def input_sequence(array)
      Ploc::SourceCode.new(array.push(nil).enum_for)
    end
    before(:each) do
      @term = Terminal.new String, 't'
      @sep  = Terminal.new String, 's'
      @smtg = Terminal.new String, '1'
      @language = Object.new
      @language.stub('nodes').and_return(term: @term, smtg: @smtg, sep: @sep)
    end
    it 'should repeat correctly until separator' do
      seq_node = Sequence.new(repeat: true, terminator: :term) { smtg }
      seq_node.language = @language

      tokens = input_sequence(%w[1 1 1 1 1 1 1 1 1 t])
      tokens.should_not_receive(:errors)
      seq_node.call(tokens.next_token, tokens).should be_nil

    end
    it 'should repeat the sequence while there are separators' do
      seq_node = Sequence.new(separator: :sep) { smtg }
      seq_node.language = @language

      tokens = input_sequence(%w[1 s 1 s 1 s 1 s 1 s 1 s 1 s 1 s 1])
      tokens.should_not_receive(:errors)
      seq_node.call(tokens.next_token, tokens).should be_nil

    end
    it 'should repeat correctly with separators until separator' do
      seq_node = Sequence.new(separator: :sep, terminator: :term) { smtg }
      seq_node.language = @language

      tokens = input_sequence(%w[1 s 1 s 1 s 1 s 1 s 1 s 1 s 1 s 1 t])
      tokens.should_not_receive(:errors)
      seq_node.call(tokens.next_token, tokens).should be_nil

    end
  end
end
