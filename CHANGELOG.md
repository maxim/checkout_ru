## 0.6.1

- Support `forcedCost` option for API Order

## 0.6.0

- Start using Faraday 0.9.1 (up from 0.8.9)

## 0.5.1

- Support for first specialized error: CheckoutRu::NoDeliveryFoundError.
  It's descendant from CheckoutRu::Error so doesn't break existing rescue code.
  It's raised when checkout.ru has no delivery for certain settlement id.
- All CheckoutRu::Error exceptions now have `code` attribute

## 0.5.0

- Support new JSON errors (includes support for JSON expired-ticket response)

## 0.4.2

- Support street property in Address (undocumented in 1.3 API, but legal to use)

## 0.4.1

- Recognize 400 status as possibly expired ticket

## 0.4.0

- Recognize checkout.ru "temporary unavailable" 500 page as expired ticket

## 0.3.0

- Make ticket auto-renewable (optional)
- Fix bug with order serialization
- Fix bug with recognizing expired ticket exception

## 0.2.0

- Add ability to pass request options to api calls

## 0.1.0

- Fix bug where CheckoutRu.api_key config didn't work
- Stop rescuing Faraday errors, instead pass them through

## 0.0.2

- Fix Faraday dependency issue
