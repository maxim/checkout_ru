require 'date'
require 'time'
require 'faraday'
require 'faraday_middleware'
require 'faraday_middleware-multi_json'
require 'nokogiri'

require 'checkout_ru/version'
require 'checkout_ru/session'
require 'checkout_ru/order'

module CheckoutRu
  SERVICE_URL = 'http://platform.checkout.ru'.freeze

  Error = Class.new(Faraday::Error::ClientError)

  class << self
    attr_accessor :service_url, :api_key, :adapter

    def get_ticket(options = {})
      key = options[:api_key] || api_key
      make_request("/service/login/ticket/#{key}")['ticket']
    end

    def create_order(order, options = {})
      make_request_with_key '/service/order/create',
        :via    => :post,
        :params => { :order => order },
        :api_key => options[:api_key]
    end

    def update_order(remote_id, order, options = {})
      make_request_with_key "/service/order/#{remote_id}",
        :via => :post,
        :params => { :order => order },
        :api_key => options[:api_key]
    end

    def status(remote_id, status, options = {})
      status_map = Order::Status::MAP

      status_string = if status.is_a?(Symbol)
        unless status_map.keys.include?(status)
          raise Error, "Invalid order status: #{status}"
        end

        status_map[status]
      else
        unless status_map.values.include?(status)
          raise Error, "Invalid order status: #{status}"
        end

        status
      end

      make_request_with_key "/service/order/status/#{remote_id}",
        :via => :post,
        :params => { :status => status_string },
        :api_key => options[:api_key]
    end

    def status_history(order_id, options = {})
      resp = make_request_with_key "/service/order/statushistory/#{order_id}",
          :api_key => options[:api_key]
      resp.order.date = Date.parse(resp.order.date)
      resp
    end

    def make_request_with_key(service, options = {})
      key = options.delete(:api_key) || api_key
      params = (options[:params] || {}).merge(:api_key => key)
      make_request service, options.merge(:params => params)
    end

    def make_request(service, options = {})
      conn   = options[:connection] || build_connection
      method = options[:via]        || :get
      params = options[:params].dup if options[:params]
      camelize_keys!(params)

      body = conn.public_send(method, service, params,
        { 'Accept' => 'application/json' }
      ).body

      underscore_keys!(body)

      case body
      when Hash
        ::Hashie::Mash.new(body)
      when Array
        body.map{|el| ::Hashie::Mash.new(el)}
      else
        body
      end
    end

    def build_connection(options = {})
      url = options[:url] || service_url || SERVICE_URL

      Faraday.new(:url => url) do |faraday|
        faraday.request :multi_json
        faraday.response :raise_error
        faraday.response :multi_json
        faraday.adapter options[:adapter] || adapter || Faraday.default_adapter
      end
    end

    def camelize_keys!(obj)
      case obj
      when Hash
        obj.replace(Hash[
          obj.map do |key, value|
            [ key.to_s.downcase.gsub(/_([a-z\d]*)/) { "#{$1.capitalize}" },
              camelize_keys!(value) ]
          end
        ])
      when Array
        obj.map! {|el| camelize_keys!(el)}
      else
        obj
      end
    end

    def underscore_keys!(obj)
      case obj
      when Hash
        obj.replace(Hash[
          obj.map do |key, value|
            [ key.to_s.gsub(/([a-z\d])([A-Z])/, '\1_\2').downcase,
              underscore_keys!(value) ]
          end
        ])
      when Array
        obj.map! {|el| underscore_keys!(el)}
      else
        obj
      end
    end
  end
end
