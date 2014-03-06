require 'test_helper'

class CheckoutRuTest < MiniTest::Test
  def build_order
    CheckoutRu::Order.new(
      :goods => [
        CheckoutRu::Item.new(
          :name          => 'blue tshirt',
          :code          => 'blt',
          :variant_code  => 'blue',
          :quantity      => 2,
          :assessed_cost => 1000,
          :pay_cost      => 750,
          :weight        => 0.5
        )
      ],

      :delivery => CheckoutRu::Delivery.new(
        :delivery_id   => 2,
        :place_fias_id => '0c5b2444-70a0-4932-980c-b4dc0d3f02b5',
        :address_pvz   => 'Энтузиастов ш.,  д. 54',
        :type          => 'postamat',
        :cost          => 224.41,
        :min_term      => 2,
        :max_term      => 11
      ),

      :user => CheckoutRu::User.new(
        :fullname => 'Вася Пупкин',
        :email    => 'vasyapupkin@example.com',
        :phone    => '555'
      ),

      :comment => 'test order',
      :shop_order_id  => '777',
      :payment_method => 'cash'
    )
  end

  def test_configured_api_key_is_used_to_make_request
    CheckoutRu.stubs(:api_key).returns('foobar')
    CheckoutRu.expects(:make_request).with("/service/login/ticket/foobar").
      once.returns({})
    CheckoutRu.get_ticket
  end

  def test_get_ticket_returns_valid_ticket
    VCR.use_cassette('get_ticket') do
      assert_equal 'valid-ticket',
        CheckoutRu.get_ticket(:api_key => 'valid-api-key')
    end
  end

  def test_get_ticket_with_invalid_api_key_raises_invalid_key_error
    VCR.use_cassette('get_ticket_invalid_api_key') do
      assert_raises Faraday::Error::ClientError do
        CheckoutRu.get_ticket(:api_key => 'invalid-api-key')
      end
    end
  end

  def test_create_order
    order = build_order

    VCR.use_cassette('create_order') do
      response = CheckoutRu.create_order(order, :api_key => 'valid-api-key')

      assert_equal 75, response.order.id
      assert_equal 2, response.delivery.id
      assert_equal 'PickPoint', response.delivery.service_name
    end
  end

  def test_update_order
    order = build_order
    order.user.fullname = 'Петя Пупкин'

    VCR.use_cassette('update_order') do
      response = CheckoutRu.update_order(75, order, :api_key => 'valid-api-key')

      assert_equal 75, response.order.id
      assert_equal 2, response.delivery.id
      assert_equal 'PickPoint', response.delivery.service_name
    end
  end

  def test_status
    VCR.use_cassette('status') do
      response = CheckoutRu.status \
        75, :cancelled_before_shipment, :api_key => 'valid-api-key'
      assert_equal '', response
    end
  end

  def test_status_history
    VCR.use_cassette('status_history') do
      response = CheckoutRu.status_history(777, :api_key => 'valid-api-key')

      assert_equal '75', response.order.id
      assert_equal Date.parse('2014-02-01'), response.order.date
      assert_equal 1724.41, response.order.total_cost
      assert_equal nil, response.order.approximate_delivery_date
      assert_equal 'Петя Пупкин', response.user.fullname
      assert_equal 'г. Москва', response.user.address.place
      assert_equal 'PickPoint', response.delivery_name
      assert_equal [], response.delivery_history
    end
  end

  def test_populated_status_history
    VCR.use_cassette('populated_status_history') do
      response = CheckoutRu.status_history(64, :api_key => 'valid-api-key')

      assert_equal '64', response.order.id
      assert_equal Date.parse('2013-10-14'), response.order.date
      assert_equal 1136.33, response.order.total_cost
      assert_equal nil, response.order.approximate_delivery_date

      assert_equal 'ввв', response.user.fullname
      assert_equal 'г. Волгоград (Волгоградская область)',
        response.user.address.place

      assert_equal 'DPD', response.delivery_name

      assert_equal 9, response.delivery_history.size
      assert_equal 'Посылка находится на терминале DPD, который осуществлял ' +
        'её приём у отправителя', response.delivery_history[0].status
      assert_equal '10.09.2013 17:19:13', response.delivery_history[0].date
    end
  end
end
