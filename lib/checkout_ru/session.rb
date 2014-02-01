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
      get('checkout/getPlacesByQuery', options).suggestions
    end

    def calculation(options = {})
      params = options.dup
      get('checkout/calculation', params)
    end

    def get_streets_by_query(options = {})
      params = options.dup
      get('checkout/getStreetsByQuery', params).suggestions
    end

    def get_postal_code_by_address(options = {})
      params = options.dup
      get('checkout/getPostalCodeByAddress', params).postindex
    end

    def get_place_by_postal_code(options = {})
      get('checkout/getPlaceByPostalCode', options)
    end

    private
    def get(service, params = {})
      CheckoutRu.make_request \
        "/service/#{service}",
        :connection => @conn,
        :params => params.merge(:ticket => @ticket)
    end
  end
end
