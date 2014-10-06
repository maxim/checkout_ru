require 'checkout_ru'
require 'minitest/autorun'
require 'mocha/mini_test'
require 'vcr'
require 'cgi'

VCR.configure do |c|
  c.cassette_library_dir = 'test/fixtures'
  c.hook_into :faraday

  # From here: https://github.com/vcr/vcr/wiki/Common-Custom-Matchers
  c.register_request_matcher :uri_ignoring_params_order do |r1, r2|
    uri1 = URI(r1.uri)
    uri2 = URI(r2.uri)

    uri1.scheme == uri2.scheme &&
      uri1.host == uri2.host &&
        uri1.path == uri2.path &&
          CGI.parse(uri1.query || '') == CGI.parse(uri2.query || '')
  end

  c.default_cassette_options = {
    match_requests_on: [:method, :uri_ignoring_params_order]
  }
end
