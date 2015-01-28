module CheckoutRu
  class Error < RuntimeError
    class << self
      def construct(response)
        code, message = parse_error_response(response)
        error_message = "#{message} (checkout.ru error, code #{code})"

        case code
        when 4   then NoDeliveryFoundError.new(error_message, code)
        when nil then new(response.inspect)
        else new(error_message, code)
        end
      end

      def parse_error_response(response)
        if response.respond_to?(:[]) &&
          response[:error_code] &&
          response[:error_message]

          [response[:error_code], response[:error_message]]
        end
      end
    end

    attr_reader :code

    def initialize(message, code = nil)
      @code = code
      super(message)
    end
  end

  NoDeliveryFoundError = Class.new(Error)
end
