# coding: utf-8
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "active_record_seek/version"

Gem::Specification.new do |spec|
  spec.name          = "active_record_seek"
  spec.version       = ActiveRecordSeek::VERSION
  spec.authors       = ["Griffith Chaffee"]
  spec.email         = ["griffithchaffee@gmail.com"]

  spec.summary       = %q{Generates useful active record query scopes.}
  spec.description   = %q{Generates useful active record scopes for attributes using Arel.}
  spec.homepage      = "https://github.com/griffithchaffee/active_record_seek"
  spec.license       = "MIT"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata["allowed_push_host"] = "TODO: Set to 'http://mygemserver.com'"
  else
    raise "RubyGems 2.0 or newer is required to protect against " \
      "public gem pushes."
  end

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler",  "~> 1.15"
  spec.add_development_dependency "rake",     "~> 10.0"
  spec.add_development_dependency "activerecord", "~> 5.0"
  spec.add_development_dependency "sqlite3",      "~> 1.3"
  spec.add_development_dependency "factory_girl", "~> 4.8"
end
