# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'skywalker/version'

Gem::Specification.new do |spec|
  spec.name          = "skywalker"
  spec.version       = Skywalker::VERSION
  spec.authors       = ["Rob Yurkowski"]
  spec.email         = ["rob@yurkowski.net"]
  spec.summary       = %q{A simple command pattern implementation for transactional operations.}
  spec.description   = %q{A simple command pattern implementation for transactional operations.}
  spec.homepage      = "https://github.com/robyurkowski/skywalker"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.required_ruby_version = '>= 2.1.2'

  spec.add_development_dependency "bundler", "~> 1.7"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "pry"
  spec.add_development_dependency "pry-byebug"
end
