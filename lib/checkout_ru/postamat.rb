require 'checkout_ru/entity'
require 'checkout_ru/delivery_calculation_properties'

module CheckoutRu
  class Postamat < Entity
    extend DeliveryCalculationProperties
  end
end
