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
session = CheckoutRu::Session.initiate
places = session.get_places_by_query('Москва')
places[0].name # => "г. Москва"
```

## Contributing

1. Fork it ( http://github.com/<my-github-username>/checkout_ru/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
