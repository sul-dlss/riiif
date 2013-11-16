# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'riiif/version'

Gem::Specification.new do |spec|
  spec.name          = "riiif"
  spec.version       = Riiif::VERSION
  spec.authors       = ["Justin Coyne"]
  spec.email         = ["justin@curationexperts.com"]
  spec.description   = %q{A IIIF image server}
  spec.summary       = %q{A rails engine that support IIIF requests}
  spec.homepage      = ""
  spec.license       = "APACHE2"

  spec.files         = `git ls-files|grep -v spec/samples`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "engine_cart"
  spec.add_development_dependency "rspec-rails"
  spec.add_dependency 'rails', '> 3.2.0'
end
