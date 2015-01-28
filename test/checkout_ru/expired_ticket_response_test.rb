require 'test_helper'

class ExpiredTicketResponseTest < MiniTest::Test
  def test_json_style_error_after_jan_2015_is_recognized
    response = {
      error: true, error_code: 3, error_message: "Ticket is expired or invalid"
    }

    assert CheckoutRu::ExpiredTicketResponse.new(response).match?
  end

  def test_old_style_error_before_jan_2015_is_recognized
    response1 = { status: 400, body: "Ticket is expired or invalid" }
    response2 = { status: 500, body: "Ticket is expired or invalid" }

    assert CheckoutRu::ExpiredTicketResponse.new(response1).match?
    assert CheckoutRu::ExpiredTicketResponse.new(response2).match?
  end

  def test_broken_error_as_of_oct_06_2014_is_recognzied
    response = { status: 500, body: "Сервис временно не доступен" }
    assert CheckoutRu::ExpiredTicketResponse.new(response).match?
  end
end
