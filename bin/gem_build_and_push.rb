#!/usr/bin/env ruby

require "bundler/setup"
require "active_record_seek"

root    = File.expand_path("../..",  __FILE__)
version = ActiveRecordSeek::VERSION

[
  "gem build #{root}/active_record_seek.gemspec",
  "gem push #{root}/active_record_seek-#{version}.gem",
].each do |command|
  puts(command)
  puts(%x{#{command}})
end
