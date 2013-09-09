# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'durable_decorator/version'

Gem::Specification.new do |spec|
  spec.name          = "durable_decorator"
  spec.version       = DurableDecorator::VERSION
  spec.authors       = ["Denis Ivanov"]
  spec.email         = ["visible.h4x@gmail.com"]
  spec.description   = "Allows method redefinitions while maintaining *super*"
  spec.summary       = "Allows method redefinitions while maintaining *super*"
  spec.homepage      = "https://github.com/jumph4x/durable-decorator"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.required_ruby_version = '>= 1.9.2'

  spec.add_dependency "method_source"
  spec.add_dependency "logging"

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
end
