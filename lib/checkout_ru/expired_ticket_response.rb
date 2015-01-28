module CheckoutRu
  class ExpiredTicketResponse
    attr_reader :response

    def initialize(response)
      @response = response || {}
    end

    def match?
      # Checkout.ru changed (broke) invalid ticket responses a few times. These
      # predicates reflect various ways we've seen that tickets can expire.
      json_style_error_after_jan_2015? ||
        old_style_error_before_jan_2015? ||
        broken_error_as_of_oct_06_2014?
    end

    def json_style_error_after_jan_2015?
      error && error_code == 3 && error_message =~ /is\s+expired\s+or\s+invalid/
    end

    def old_style_error_before_jan_2015?
      [400, 500].include?(status) && body =~ /is\s+expired\s+or\s+invalid/
    end

    def broken_error_as_of_oct_06_2014?
      status == 500 && body =~ /Сервис\s+временно\s+не\s+доступен/
    end

    private

    def error;         response[:error]         end
    def error_code;    response[:error_code]    end
    def error_message; response[:error_message] end
    def body;          response[:body]          end
    def status;        response[:status]        end
  end
end
