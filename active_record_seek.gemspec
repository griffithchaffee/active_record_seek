# coding: utf-8
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "active_record_seek/version"

Gem::Specification.new do |spec|

  spec.name          = "active_record_seek"
  spec.version       = ActiveRecordSeek::VERSION
  spec.authors       = ["Griffith Chaffee"]
  spec.email         = ["griffithchaffee@gmail.com"]

  spec.summary       = %q{Build complex ActiveRecord queries using hash syntax.}
  spec.description   = %q{Build complex ActiveRecord queries using hash syntax. Includes support for Arel operators, OR queries, and assocition subqueries.}
  spec.homepage      = "https://github.com/griffithchaffee/active_record_seek"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject do |file_name|
    file_name.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency("bundler",      "~> 2")
  spec.add_development_dependency("rake",         "~> 13")
  spec.add_development_dependency("activerecord", "~> 5")
  spec.add_development_dependency("factory_bot",  "~> 5")
  spec.add_development_dependency("byebug",       "~> 11")

end
