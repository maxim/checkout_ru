require 'checkout_ru/entity'

module CheckoutRu
  class Address < Entity
    property :postindex
    property :street_fias_id, :from => :streetFiasId
    property :house
    property :housing
    property :building
    property :appartment # [sic]
  end
end
