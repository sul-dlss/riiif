# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'riiif/version'

Gem::Specification.new do |spec|
  spec.name          = 'riiif'
  spec.version       = Riiif::VERSION
  spec.authors       = ['Justin Coyne']
  spec.email         = ['justin@curationexperts.com']
  spec.description   = 'A IIIF image server'
  spec.summary       = 'A rails engine that support IIIF requests'
  spec.homepage      = 'https://github.com/curationexperts/riiif'
  spec.license       = 'APACHE2'

  spec.files         = `git ls-files|grep -v spec/samples`.split($INPUT_RECORD_SEPARATOR)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_dependency 'railties', '>= 4.2', '<6'
  spec.add_dependency 'deprecation', '>= 1.0.0'
  spec.add_development_dependency 'bundler', '~> 1.3'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'engine_cart', '~> 2.0'
  spec.add_development_dependency 'rspec-rails'
  spec.add_development_dependency 'sqlite3'
  spec.add_development_dependency 'rubocop', '~> 0.47.1'
  spec.add_development_dependency 'rubocop-rspec', '~> 1.13'
  spec.add_development_dependency 'coveralls'
end
