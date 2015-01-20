module CheckoutRu
  class Session
    # Checkout.ru changed (broke) invalid ticket responses a few times. This
    # matcher reflects all varieties of them.
    INVALID_TICKET_RESPONSE_MATCHER = /is\s+expired\s+or\s+invalid/x.freeze
    INVALID_TICKET_RESPONSE_CODE = 3

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
      parsed_response =
        CheckoutRu.make_request "/service/checkout/#{service}", args

      if CheckoutRu.auto_renew_session &&
          expired_ticket?(parsed_response) && attempts > 0

        @ticket = CheckoutRu.get_ticket
        get(service, params, options.merge(attempts: attempts - 1))
      else
        parsed_response
      end
    rescue Faraday::Error::ClientError => e
      if CheckoutRu.auto_renew_session &&
        attempts > 0 && expired_ticket_exception?(e)

        @ticket = CheckoutRu.get_ticket
        get(service, params, options.merge(attempts: attempts - 1))
      else
        raise
      end
    end

    def build_connection
      @connection ||= CheckoutRu.build_connection
    end

    def expired_ticket?(response)
      response[:error] &&
        response[:error_code] == INVALID_TICKET_RESPONSE_CODE &&
        response[:error_message].force_encoding('utf-8') =~
          INVALID_TICKET_RESPONSE_MATCHER
    end
  end
end
