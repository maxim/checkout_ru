module CheckoutRu
  class Session
    class << self
      def initiate
        ticket = CheckoutRu.get_ticket
        new(ticket)
      end
    end

    def initialize(ticket)
      @ticket = ticket
      @conn = CheckoutRu.build_connection
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
      args = {
        :connection => @conn,
        :params => params.merge(:ticket => @ticket)
      }.merge(options)

      CheckoutRu.make_request "/service/checkout/#{service}", args
    end
  end
end
