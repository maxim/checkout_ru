require 'test_helper'

class CheckoutRuTest < MiniTest::Test
  def test_get_ticket_returns_valid_ticket
    VCR.use_cassette('get_ticket') do
      assert_equal 'valid-ticket', CheckoutRu.get_ticket('valid-api-key')
    end
  end

  def test_get_ticket_with_invalid_api_key_raises_invalid_key_error
    VCR.use_cassette('get_ticket_invalid_api_key') do
      assert_raises CheckoutRu::Error do
        CheckoutRu.get_ticket('invalid-api-key')
      end
    end
  end
end
