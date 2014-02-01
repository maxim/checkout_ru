require 'checkout_ru/entity'

module CheckoutRu
  class User < Entity
    property :fullname
    property :email
    property :phone
  end
end
