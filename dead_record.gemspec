# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'dead_record/version'

Gem::Specification.new do |spec|
  spec.name          = "dead_record"
  spec.version       = DeadRecord::VERSION
  spec.authors       = ["Imad Mouaddine"]
  spec.email         = ["imad@ecomstrategy.ca"]
  spec.summary       = %q{Allow active_record models to be soft deleted.}
  spec.description   = %q{Please do not use in production yet.}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.7"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency 'rspec'
  spec.add_development_dependency 'sqlite3'
  spec.add_development_dependency "coveralls"

  spec.add_dependency "activerecord", "~> 4.0"

end
