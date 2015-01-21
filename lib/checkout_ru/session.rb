module CheckoutRu
  class Session
    # Checkout.ru changed (broke) invalid ticket responses a few times. These
    # hashes reflect various ways we've seen up to date that ticket can expire.
    EXPIRED_TICKET_MATCHERS = [
      # the new JSON errors
      lambda { |r|
        r[:error] &&
          r[:error_code] == 3 &&
          r[:error_message] =~ /is\s+expired\s+or\s+invalid/
      },

      # before JSON errors were introduced
      lambda { |r|
        [400, 500].include?(r[:status]) &&
          r[:body] =~ /is\s+expired\s+or\s+invalid/
      },

      # broken style as of 10-06-14
      lambda { |r|
        r[:status] == 500 && r[:body] =~ /Сервис\s+временно\s+не\s+доступен/
      }
    ].freeze

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
      parsed_response && EXPIRED_TICKET_MATCHERS.any? do |matcher|
        matcher.call(parsed_response)
      end
    end
  end
end
