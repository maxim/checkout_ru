require 'checkout_ru/entity'
require 'checkout_ru/delivery_calculation_properties'

module CheckoutRu
  class Pvz < Entity
    extend DeliveryCalculationProperties
  end
end
