require 'checkout_ru/entity'

module CheckoutRu
  class Express < Entity
    property :delivery_id, :from => :deliveryId
    property :cost
    property :min_delivery_term, :from => :minDeliveryTerm
    property :max_delivery_term, :from => :maxDeliveryTerm
    property :index_of_the_cheapest_terminal,
      :from => :indexOfTheCheapestTerminal
    property :additional_info, :from => :additionalInfo
  end
end
