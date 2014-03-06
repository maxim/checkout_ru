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
      key = options.delete(:api_key) || api_key
      make_request("/service/login/ticket/#{key}", options)['ticket']
    end

    def create_order(order, options = {})
      args = {
        :via    => :post,
        :params => { :order => order }
      }.merge(options)

      make_request_with_key '/service/order/create', args
    end

    def update_order(remote_id, order, options = {})
      args = {
        :via => :post,
        :params => { :order => order }
      }.merge(options)

      make_request_with_key "/service/order/#{remote_id}", args
    end

    def status(remote_id, status, options = {})
      args = {
        :via => :post,
        :params => { :status => parse_status(status) }
      }.merge(options)

      make_request_with_key "/service/order/status/#{remote_id}", args
    end

    def status_history(order_id, options = {})
      resp = make_request_with_key "/service/order/statushistory/#{order_id}",
        options
      resp.order.date = Date.parse(resp.order.date)
      resp
    end

    def parse_status(status)
      status_map = Order::Status::MAP

      if status.is_a?(Symbol)
        unless Order::Status::MAP.keys.include?(status)
          raise Error, "Invalid order status: #{status}"
        end

        Order::Status::MAP[status]
      else
        unless Order::Status::MAP.values.include?(status)
          raise Error, "Invalid order status: #{status}"
        end

        status
      end
    end

    def make_request_with_key(service, options = {})
      key = options.delete(:api_key) || api_key
      params = (options[:params] || {}).merge(:api_key => key)
      make_request service, options.merge(:params => params)
    end

    def make_request(service, options = {})
      headers      = { 'Accept' => 'application/json' }
      conn         = options[:connection] || build_connection
      method       = options[:via]        || :get
      request_opts = options[:request]    || {}
      params       = options[:params].dup if options[:params]

      camelize_keys!(params)

      body = conn.public_send(method, service, params, headers) do |req|
        req.options.update(request_opts) unless request_opts.empty?
      end.body

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
