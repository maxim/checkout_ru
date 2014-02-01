# CheckoutRu

Thin ruby client for checkout.ru integration.

## Installation

Add this line to your application's Gemfile:

    gem 'checkout_ru'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install checkout_ru

## Usage

```ruby
CheckoutRu.api_key = 'my-api-key'

session = CheckoutRu::Session.initiate
places = session.get_places_by_query('Москва')
places[0].name # => "г. Москва"

order = CheckoutRu::Order.new(
  goods: [
    CheckoutRu::Item.new(
      name:          'blue tshirt',
      code:          'blt',
      variant_code:  'blue',
      quantity:      2,
      assessed_cost: 1000,
      pay_cost:      750,
      weight:        0.5
    )
  ],

  delivery: CheckoutRu::Delivery.new(
    delivery_id:   2,
    place_fias_id: '0c5b2444-70a0-4932-980c-b4dc0d3f02b5',
    address_pvz:   'Энтузиастов ш.,  д. 54',
    type:          'postamat',
    cost:          224.41,
    min_term:      2,
    max_term:      11
  ),

  user: CheckoutRu::User.new(
    fullname: 'Вася Пупкин',
    email:    'vasyapupkin@example.com',
    phone:    '555'
  ),

  comment:        'test order',
  shop_order_id:  '777',
  payment_method: 'cash'
)

CheckoutRu.create_order(order)
# => '{"order":{"id":75},"delivery":{"id":2,"serviceName":"PickPoint"}}'
```

## Contributing

1. Fork it ( http://github.com/maxim/checkout_ru/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
