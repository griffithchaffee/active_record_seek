require "bundler/gem_tasks"
require "rake/testtask"

DB_ADAPTER_NAMES = %w[ postgresql sqlite mysql ]

namespace :test do

  Rake::TestTask.new(:run) do |t|
    t.libs << "test"
    t.libs << "lib"
    t.test_files = FileList["test/**/*_test.rb"]
  end

  DB_ADAPTER_NAMES.each do |adapter_namespace|
    desc "Run tests with #{adapter_namespace} adapter"
    task(adapter_namespace) do
      # ENV["BUNDLE_GEMFILE"] = "gemfiles/#{adapter_namespace}.gemfile"
      # Bundler.setup
      ENV["TEST_DB_ADAPTER"] = adapter_namespace
      Rake::Task["test:run"].reenable
      Rake::Task["test:run"].invoke
    end
  end
end

desc "Run all tests for each DB adapter"
task default: DB_ADAPTER_NAMES.map {|db| "test:#{db}"}
