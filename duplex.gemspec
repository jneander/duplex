# coding: utf-8
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "duplex/version"

Gem::Specification.new do |spec|
  spec.name          = "duplex"
  spec.version       = Duplex::VERSION
  spec.authors       = ["Jeremy Neander"]
  spec.email         = ["jeremy.neander@gmail.com"]
  spec.summary       = %Q{Find and manage your duplicate files.}
  spec.description   = %Q{Find duplicate files and apply your own rules for keeping to ones you want and destroying the rest.}
  spec.homepage      = "http://github.com/jneander/duplex"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^spec/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.7"
  spec.add_development_dependency "guard", "~> 2.12"
  spec.add_development_dependency "guard-rspec", "~> 4.5"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.2"
end
