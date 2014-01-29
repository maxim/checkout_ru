require 'checkout_ru/entity'

module CheckoutRu
  class Place < Entity
    property :id
    property :name
    property :full_name, :from => :fullName
  end
end
