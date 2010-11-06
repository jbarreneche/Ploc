#!/usr/bin/env ruby -w

$:.unshift File.expand_path(File.join(File.dirname(__FILE__), *%w[.. lib]))

require 'ploc/pl0'
require 'fileutils'

if ARGV.empty?
  STDERR.puts "** You must pass inform the source code filename" 
  exit 1
end

unless File.readable?(filename = ARGV.shift)
  STDERR.puts "** can't read file: #{filename}" 
  exit 1
end

File.open(filename) do |input|
  parts = filename.split('.')
  if parts.size == 1
    parts << "out" 
  else
    parts.pop
  end
  output_name = parts.join('.')
  out = File.open(output_name, 'wb') rescue nil
  output_name = output_name + ".out" unless out
  out = File.open(output_name, 'wb') rescue nil
  unless out
    STDERR.puts "** can't write output to file: #{output_name}" 
    exit 1
  end
  context = Ploc::PL0::Language.compile input, out
  puts "Errors: #{context.source_code.errors}"
  FileUtils.chmod 0755, output_name
end

