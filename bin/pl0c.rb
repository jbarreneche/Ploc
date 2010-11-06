#!/usr/bin/env ruby -w

$:.unshift File.expand_path(File.join(File.dirname(__FILE__), *%w[.. lib]))
require 'ploc/pl0'
require 'stringio'
# @s =  
out = File.open('tsss.s', 'wb')
Ploc::PL0::Language.context_builder= ->(source_code) { Ploc::PL0::CompilingContext.new(source_code, out) }
e = Ploc::PL0::Language.compile StringIO.new(".")
# out.close
puts e.instance_variable_get("@pending_fix_jumps").inspect
puts e.inspect

# e.output.each do |o|
#   puts o.inspect
# end