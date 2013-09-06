# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'rnotifier/version'

Gem::Specification.new do |spec|
  spec.name          = 'rnotifier'
  spec.version       = Rnotifier::VERSION
  spec.authors       = ['Jiren Patel']
  spec.email         = ['jirenpatel@gmail.com']
  spec.description   = %q{Exception catcher}
  spec.summary       = %q{Exception catcher for Rails and other Rack apps}
  spec.homepage      = 'https://github.com/jiren/rnotifier'
  spec.license       = 'MIT'

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_dependency 'faraday', '>= 0.8.7'
  #spec.add_dependency 'yajl-ruby', '>= 1.1.0'
  spec.add_dependency 'multi_json', '>= 1.7.2'
  spec.add_development_dependency 'bundler', '~> 1.3'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'sinatra'
  spec.add_development_dependency 'rspec-rails'
  spec.add_development_dependency 'rspec-expectations'
end
