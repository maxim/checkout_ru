# coding: utf-8

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
        :address_pvz   => '1-я Квесисская улица, 18',
        :type          => 'postamat',
        :cost          => 250,
        :min_term      => 1,
        :max_term      => 2
      ),

      :user => CheckoutRu::User.new(
        :fullname => 'Test Order',
        :email    => 'testorder@example.com',
        :phone    => '+79876543210'
      ),

      :comment => 'TEST ORDER',
      :payment_method => 'cash'
    )
  end

  def create_order
    CheckoutRu.create_order(build_order).order.id
  end

  def test_configured_api_key_is_used_to_make_request
    CheckoutRu.stubs(:api_key).returns('foobar')
    CheckoutRu.expects(:make_request).with('/service/login/ticket/foobar', {}).
      once.returns({})
    CheckoutRu.get_ticket
  end

  def test_get_ticket_returns_valid_ticket
    VCR.use_cassette('get_ticket') do
      assert_match /\A[a-f0-9]{32,}\Z/,
        CheckoutRu.get_ticket(:api_key => CheckoutRu.api_key)
    end
  end

  def test_get_ticket_with_invalid_api_key_returns_nil
    VCR.use_cassette('get_ticket_invalid_api_key') do
      assert_nil CheckoutRu.get_ticket(:api_key => 'invalid-api-key')
    end
  end

  def test_create_order
    VCR.use_cassette('create_order') do
      order = build_order
      response = CheckoutRu.create_order(order)

      assert_match /\A\d+\Z/, response.order.id.to_s
      assert_equal 2, response.delivery.id
      assert_equal 'PickPoint', response.delivery.service_name
    end
  end

  def test_update_order
    VCR.use_cassette('update_order') do
      id = create_order

      order = build_order
      order.user.fullname = 'Петя Пупкин'
      response = CheckoutRu.update_order(id, order)

      assert_equal id, response.order.id
      assert_equal 2, response.delivery.id
      assert_equal 'PickPoint', response.delivery.service_name
    end
  end

  def test_status
    VCR.use_cassette('status') do
      id = create_order
      response = CheckoutRu.status(id, :cancelled_before_shipment)
      assert_equal '', response
    end
  end

  def test_status_history
    VCR.use_cassette('status_history') do
      id = create_order
      response = CheckoutRu.status_history(id)

      assert_equal id, response.order.id.to_i
      assert_kind_of Date, response.order.date
      assert_kind_of Float, response.order.total_cost
      assert_equal 'Test Order', response.user.fullname
      assert_equal 'г. Москва', response.user.address.place
      assert_equal 'PickPoint', response.delivery_name
      assert_equal [], response.delivery_history
    end
  end

  def test_populated_status_history
    VCR.use_cassette('populated_status_history') do
      response = CheckoutRu.status_history(44391)

      assert_equal '33195', response.order.id
      assert_equal Date.parse('2014-10-07'), response.order.date
      assert_equal 1320.0, response.order.total_cost
      assert_nil response.order.approximate_delivery_date

      assert_equal 'Ольга Суржик', response.user.fullname
      assert_equal 'г. Великий Новгород (Новгородская область)',
        response.user.address.place

      assert_equal 'SPSR', response.delivery_name

      assert_equal 4, response.delivery_history.size
      assert_equal 'Москва - Хранилище неперерегистрированного', response.delivery_history[0].status
      assert_equal '07.10.2014 17:01:00', response.delivery_history[0].date
    end
  end
end
