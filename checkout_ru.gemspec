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
  spec.homepage      = ''
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency 'bundler', '~> 1.5'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'minitest', '~> 5.2.2'
end
