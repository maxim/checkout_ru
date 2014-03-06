require 'test_helper'

class CheckoutRu::SessionTest < MiniTest::Test
  def setup
    @session = CheckoutRu::Session.new('valid-ticket')
  end

  def test_request_options_are_passed_through_to_faraday
    CheckoutRu.expects(:make_request).once.with(
      '/service/checkout/calculation', has_entry(:request, { :timeout => 5 })
    )
    @session.calculation({}, :request => { :timeout => 5 })
  end

  def test_get_places_by_query
    VCR.use_cassette('get_places_by_query') do
      places = @session.get_places_by_query(:place => 'москва')

      assert_equal 4, places.size

      assert_equal '0c5b2444-70a0-4932-980c-b4dc0d3f02b5', places[0].id
      assert_equal 'Москва', places[0].name
      assert_equal 'г. Москва', places[0].full_name

      assert_equal '3605e660-e90e-47d3-b58e-068f24e68145', places[1].id
      assert_equal 'Москва', places[1].name
      assert_equal 'д. Москва (Пеновский район, Тверская область)',
        places[1].full_name
    end
  end

  def test_calculation
    VCR.use_cassette('calculation') do
      calculation = @session.calculation(
        :place_id     => '0c5b2444-70a0-4932-980c-b4dc0d3f02b5',
        :total_sum    => 1500,
        :assessed_sum => 2000,
        :items_count  => 2,
        :total_weight => 1
      )

      assert calculation.keys.include?('postamat')
      assert calculation.keys.include?('pvz')
      assert calculation.keys.include?('express')

      assert_equal 73, calculation.postamat.costs.size
      assert_equal 68, calculation.pvz.costs.size
      assert_equal 340, calculation.express.cost
    end
  end

  def test_get_streets_by_query
    VCR.use_cassette('get_streets_by_query') do
      streets = @session.get_streets_by_query(
        :street => 'мас',
        :place_id => '0c5b2444-70a0-4932-980c-b4dc0d3f02b5'
      )

      assert_equal '960972e8-48bb-4837-b0ee-ee0347931b73', streets[0].id
      assert_equal 'Масловка Верхн.', streets[0].name
      assert_equal 'ул', streets[0].type

      assert_equal 'ad4b99f0-33da-4661-aa29-057557cf4147', streets[1].id
      assert_equal 'Масловка Нижн.', streets[1].name
      assert_equal 'ул', streets[1].type
    end
  end

  def test_get_postal_code_by_address
    VCR.use_cassette('get_postal_code_by_address') do
      postal_code = @session.get_postal_code_by_address(
        :street_id => '2b453e3c-d908-4608-b81c-a314a687bee3',
        :house => 13, :housing => '', :building => ''
      )

      assert_equal '111524', postal_code
    end
  end

  def test_get_place_by_postal_code
    VCR.use_cassette('get_place_by_postal_code') do
      place = @session.get_place_by_postal_code(:post_index => '111524')

      assert_equal '0c5b2444-70a0-4932-980c-b4dc0d3f02b5', place.id
      assert_equal 'Москва', place.name
      assert_equal 'г. Москва', place.full_name
    end
  end
end
