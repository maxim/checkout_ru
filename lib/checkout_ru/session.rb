require 'checkout_ru/place'
require 'checkout_ru/calculation'
require 'checkout_ru/street'
require 'nokogiri'

module CheckoutRu
  class Session
    class << self
      def initiate
        ticket = CheckoutRu.get_ticket
        new(ticket)
      end
    end

    def initialize(ticket, options = {})
      @ticket = ticket
      @conn = CheckoutRu.build_connection
    end

    def get_places_by_query(options = {})
      array = get('checkout/getPlacesByQuery', options)['suggestions']
      array.map { |hash| Place.new(hash) }
    end

    def calculation(options = {})
      params = options.dup
      params[:place_id] ||= params.delete(:place).id
      hash = get('checkout/calculation', params)
      Calculation.new(hash)
    end

    def get_streets_by_query(options = {})
      params = options.dup
      params[:place_id] ||= params.delete(:place).id
      array = get('checkout/getStreetsByQuery', params)['suggestions']
      array.map { |hash| Street.new(hash) }
    end

    def get_postal_code_by_address(options = {})
      params = options.dup
      params[:street_id] ||= params.delete(:street).id
      get('checkout/getPostalCodeByAddress', params)['postindex']
    end

    def get_place_by_postal_code(options = {})
      hash = get('checkout/getPlaceByPostalCode', options)
      Place.new(hash)
    end

    private
    def get(service = '', params = {})
      params = CheckoutRu.camelize_keys(params)
      resp = @conn.get("/service/#{service}",
        params.merge(:ticket => @ticket),
        'Accept' => 'application/json'
      )
      resp.body
    rescue Faraday::Error::ClientError => e
      begin
        doc = Nokogiri::HTML(e.response[:body])
        doc.css('script, link').each(&:remove)
        msg = doc.css('body h1').text
      rescue
        raise e
      else
        raise Error, msg
      end
    end
  end
end
