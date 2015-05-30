require 'checkout_ru'
require 'minitest/autorun'
require 'mocha/mini_test'
require 'vcr'
require 'cgi'

REAL_API_KEY = ENV['CHECKOUT_RU_API_KEY']
FAKE_API_KEY = 'valid-api-key'

CheckoutRu.api_key = REAL_API_KEY || FAKE_API_KEY
CheckoutRu.auto_renew_session = true

VCR.configure do |c|
  c.cassette_library_dir = 'test/fixtures'

  # Typically we'd hook into :faraday here, since that's what checkout_ru uses,
  # but due to an issue we must use a workaround, hook directly into underlying
  # library (webmock). Issue also referred to in checkout_ru.gemspec.
  # https://github.com/vcr/vcr/issues/386
  c.hook_into :webmock

  if REAL_API_KEY
    c.filter_sensitive_data(FAKE_API_KEY) { REAL_API_KEY }
  end

  c.before_record do |i|
    i.response.body.force_encoding('UTF-8')
  end

  # From here: https://github.com/vcr/vcr/wiki/Common-Custom-Matchers
  c.register_request_matcher :uri_ignoring_params_order do |r1, r2|
    uri1 = URI(r1.uri)
    uri2 = URI(r2.uri)

    uri1.scheme == uri2.scheme &&
      uri1.host == uri2.host &&
        uri1.path == uri2.path &&
          CGI.parse(uri1.query || '') == CGI.parse(uri2.query || '')
  end

  cassette_options = {
    :match_requests_on => [:method, :uri_ignoring_params_order],
    :decode_compressed_response => true
  }
  cassette_options.merge!(:re_record_interval => 0) if REAL_API_KEY
  c.default_cassette_options = cassette_options
end
