require 'faraday'
require 'faraday_middleware'
require 'checkout_ru/version'
require 'checkout_ru/session'

module CheckoutRu
  SERVICE_URL = 'http://platform.checkout.ru'.freeze

  Error = Class.new(Faraday::Error::ClientError)
  InvalidApiKeyError = Class.new(Error)

  class << self
    attr_accessor :api_key, :adapter

    def build_connection(options = {})
      Faraday.new(:url => options[:url] || SERVICE_URL) do |faraday|
        faraday.request :url_encoded
        faraday.response :json
        faraday.response :raise_error
        faraday.adapter options[:adapter] || adapter || Faraday.default_adapter
      end
    end

    def get_ticket(api_key = api_key)
      conn = build_connection
      conn.get("/service/login/ticket/#{api_key}").body['ticket']
    rescue Faraday::Error::ClientError => e
      raise Error, e.response[:body].force_encoding('utf-8')
    end

    def camelize_keys(hash)
      Hash[
        hash.map do |key, value|
          [key.to_s.downcase.gsub(/_([a-z\d]*)/) { "#{$1.capitalize}" }, value]
        end
      ]
    end
  end
end
