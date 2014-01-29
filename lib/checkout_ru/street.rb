require 'checkout_ru/entity'

module CheckoutRu
  class Street < Entity
    property :id
    property :name
    property :type
  end
end
