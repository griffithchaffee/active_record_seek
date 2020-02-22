require "bundler/gem_tasks"
require "rake/testtask"

namespace :test do
  Rake::TestTask.new(:run) do |t|
    t.libs << "test"
    t.libs << "lib"
    t.test_files = FileList["test/**/*_test.rb"]
  end

  %w[ postgresql sqlite mysql ].each do |adapter_namespace|
    desc "run tests with #{adapter_namespace} adapter"
    task(adapter_namespace) do
      ENV["BUNDLE_GEMFILE"] = "gemfiles/#{adapter_namespace}.gemfile"
      Bundler.setup
      Rake::Task["test:run"].invoke
    end
  end
end

task :default => "test:sqlite"
