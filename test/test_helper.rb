require 'checkout_ru'
require 'minitest/autorun'
require 'mocha/mini_test'
require 'vcr'

VCR.configure do |c|
  c.cassette_library_dir = 'test/fixtures'
  c.hook_into :faraday
end
