#!/usr/bin/env ruby

require "bundler/setup"
require "active_record_seek"

root = File.expand_path("../..",  __FILE__)
version = ActiveRecordSeek::VERSION

#%x{gem build #{root}/active_record_seek.gemspec}
#%x{gem publish #{root}/active_record_seek-#{version}.gem}
puts "gem build #{root}/active_record_seek.gemspec"
puts "gem publish #{root}/active_record_seek-#{version}.gem"
