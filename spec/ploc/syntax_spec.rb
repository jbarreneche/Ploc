require 'spec_helper'
require 'ploc/syntax'

describe Ploc::Syntax do
  let(:node1) { stub('Node1').as_null_object }
  let(:node2) { stub('Node2').as_null_object }
  it 'should know his nodes' do
    syntax = Ploc::Syntax.new some_node: node1, another_node: node2
    syntax.nodes.should == {some_node: node1, another_node: node2}
  end
end