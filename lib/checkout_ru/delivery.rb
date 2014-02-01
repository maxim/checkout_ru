require 'checkout_ru/entity'
require 'checkout_ru/address'

module CheckoutRu
  class Delivery < Entity
    property :delivery_id,     :required => true, :from => :deliveryId
    property :place_fias_id,   :required => true, :from => :placeFiasId

    property :address_express, :from => :addressExpress
    property :address_pvz,     :from => :addressPvz

    property :type,     :required => true
    property :cost,     :required => true
    property :min_term, :required => true, :from => :minTerm
    property :max_term, :required => true, :from => :maxTerm

    coerce_key :address_express, Address
  end
end
