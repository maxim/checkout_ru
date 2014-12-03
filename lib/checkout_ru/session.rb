module CheckoutRu
  class Session
    # Checkout.ru changed (broke) invalid ticket responses a few times. This
    # matcher reflects all varieties of them.
    INVALID_TICKET_RESPONSE_MATCHER = %r{
      (?:is\s+expired\s+or\s+invalid|     # old working style
       Сервис\s+временно\s+не\s+доступен) # broken style as of 10-06-14
    }x.freeze

    TICKET_ERROR_RESPONSE_STATUSES = [400, 500].freeze

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
      session_renewal_count ||= 0
      session_renewal_count += 1
      args = {:params => params.merge(:ticket => @ticket)}.merge(options)
      args[:connection] ||= build_connection
      CheckoutRu.make_request "/service/checkout/#{service}", args
    rescue Faraday::Error::ClientError => e
      if CheckoutRu.auto_renew_session &&
        session_renewal_count < 2 && expired_ticket_exception?(e)
        @ticket = CheckoutRu.get_ticket
        retry
      else
        raise
      end
    end

    def build_connection
      @connection ||= CheckoutRu.build_connection
    end

    def expired_ticket_exception?(exception)
      exception.respond_to?(:response) &&
        exception.response.respond_to?(:[]) &&
        TICKET_ERROR_RESPONSE_STATUSES.include?(exception.response[:status]) &&
        exception.response[:body].force_encoding('utf-8') =~
          INVALID_TICKET_RESPONSE_MATCHER
    end
  end
end
