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
      args = {:params => params.merge(:ticket => @ticket)}.merge(options)
      args[:connection] ||= build_connection
      CheckoutRu.make_request "/service/checkout/#{service}", args
    rescue Faraday::Error::ClientError => e
      if CheckoutRu.auto_renew_session && expired_ticket_exception?(e)
        @ticket = CheckoutRu.get_ticket
      else
        raise
      end
    end

    def build_connection
      @connection ||= CheckoutRu.build_connection
    end

    def expired_ticket_exception?(exception)
      exception.respond_to?(:response) &&
        exception.response[:status] == 500 &&
        exception.response[:body] =~ /#{@ticket}\s+is\s+expired\s+or\s+invalid/
    end
  end
end
