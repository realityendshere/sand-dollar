# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'sand-dollar/resources/version'

Gem::Specification.new do |spec|
  spec.name          = "sand-dollar"
  spec.version       = SandDollar::Resources::VERSION
  spec.authors       = ["Dana Franklin"]
  spec.email         = ["danaf@mediaartslab.com"]
  spec.summary       = %q{Ridiculously basic authentication for a Rails API.}
  spec.description   = %q{Ridiculously basic authentication for a Rails API.}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "bcrypt", "~> 3.1"

  spec.add_development_dependency "bundler", "~> 1.7"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency 'rspec'
end
