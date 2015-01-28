require 'checkout_ru/expired_ticket_response'

module CheckoutRu
  class Session
    class << self
      def initiate
        ticket = CheckoutRu.get_ticket
        new(ticket)
      end
    end

    attr_reader :ticket

    def initialize(ticket)
      @ticket = ticket
    end

    def get_places_by_query(params = {}, options = {})
      get('getPlacesByQuery', params, options).suggestions
    end

    def calculation(params = {}, options = {})
      get('calculation', params, options)
    end

    def get_streets_by_query(params = {}, options = {})
      get('getStreetsByQuery', params, options).suggestions
    end

    def get_postal_code_by_address(params = {}, options = {})
      get('getPostalCodeByAddress', params, options).postindex
    end

    def get_place_by_postal_code(params = {}, options = {})
      get('getPlaceByPostalCode', params, options)
    end

    private
    def get(service, params = {}, options = {})
      attempts = options.delete(:attempts) || 2

      args = {:params => params.merge(:ticket => @ticket)}.merge(options)
      args[:connection] ||= build_connection

      begin
        parsed_response =
          CheckoutRu.make_request "/service/checkout/#{service}", args
      rescue Faraday::Error::ClientError => e
        parsed_response = e.response if e.respond_to?(:response) &&
          e.response.respond_to?(:[])

        raise unless expired_ticket?(parsed_response)
      end

      if CheckoutRu.auto_renew_session &&
        attempts > 0 && expired_ticket?(parsed_response)

        @ticket = CheckoutRu.get_ticket
        parsed_response =
          get(service, params, options.merge(attempts: attempts - 1))
      end

      if parsed_response[:error]
        msg = "Error code: #{parsed_response[:error_code]}. "\
          "Error message: #{parsed_response[:error_message]}"

        raise Error, msg
      end

      parsed_response
    end

    def build_connection
      @connection ||= CheckoutRu.build_connection
    end

    def expired_ticket?(parsed_response)
      ExpiredTicketResponse.new(parsed_response).match?
    end
  end
end
