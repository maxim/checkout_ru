require 'checkout_ru/entity'
require 'checkout_ru/postamat'
require 'checkout_ru/pvz'
require 'checkout_ru/express'

module CheckoutRu
  class Calculation < Entity
    property :postamat
    property :pvz
    property :express

    coerce_key :postamat, Postamat
    coerce_key :pvz, Pvz
    coerce_key :express, Express
  end
end
