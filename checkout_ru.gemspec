# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'checkout_ru/version'

Gem::Specification.new do |spec|
  spec.name          = "checkout_ru"
  spec.version       = CheckoutRu::VERSION
  spec.authors       = ["Maxim Chernyak"]
  spec.email         = ["max@bitsonnet.com"]
  spec.summary       = %q{Ruby client for checkout.ru}
  spec.description   = %q{Ruby client for checkout.ru.}
  spec.homepage      = 'http://github.com/maxim/checkout_ru'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency 'faraday', '~> 0.8.9'
  spec.add_runtime_dependency 'faraday_middleware', '~> 0.9'
  spec.add_runtime_dependency 'faraday_middleware-multi_json', '~> 0.0'
  spec.add_runtime_dependency 'multi_json', '~> 1.8'
  spec.add_runtime_dependency 'hashie', '~> 2.0'
  spec.add_runtime_dependency 'nokogiri', '~> 1.6'

  spec.add_development_dependency 'bundler', '~> 1.5'
  spec.add_development_dependency 'rake', '~> 10'
  spec.add_development_dependency 'minitest', '~> 5.2'
  spec.add_development_dependency 'vcr', '~> 2.8'
  spec.add_development_dependency 'mocha', '~> 1.0'
end
