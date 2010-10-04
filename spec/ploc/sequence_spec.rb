require 'spec_helper'
require 'ploc/language_node'

describe Ploc::LanguageNode::Sequence do
  def input_sequence(array)
    array.push(nil).enum_for
  end
  before(:each) do
    @term = Ploc::LanguageNode::Terminal.new String, 't'
    @sep  = Ploc::LanguageNode::Terminal.new String, 's'
    @smtg = Ploc::LanguageNode::Terminal.new String, '1'
    @language = Object.new
    @language.stub('nodes').and_return(term: @term, smtg: @smtg, sep: @sep)
  end
  it 'should repeat correctly until separator' do
    seq_node = Ploc::LanguageNode::Sequence.new(repeat: true, terminator: :term) { smtg }
    seq_node.language = @language

    @language.should_not_receive(:errors)
    tokens = input_sequence(%w[1 1 1 1 1 1 1 1 1 t])
    seq_node.call(tokens.next, tokens).should be_nil

  end
  it 'should repeat the sequence while there are separators' do
    seq_node = Ploc::LanguageNode::Sequence.new(separator: :sep) { smtg }
    seq_node.language = @language

    @language.should_not_receive(:errors)
    tokens = input_sequence(%w[1 s 1 s 1 s 1 s 1 s 1 s 1 s 1 s 1])
    seq_node.call(tokens.next, tokens).should be_nil

  end
  it 'should repeat correctly with separators until separator' do
    seq_node = Ploc::LanguageNode::Sequence.new(separator: :sep, terminator: :term) { smtg }
    seq_node.language = @language

    @language.should_not_receive(:errors)
    tokens = input_sequence(%w[1 s 1 s 1 s 1 s 1 s 1 s 1 s 1 s 1 t])
    seq_node.call(tokens.next, tokens).should be_nil

  end
end