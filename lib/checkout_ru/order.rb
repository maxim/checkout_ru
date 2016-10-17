require 'checkout_ru/entity'
require 'checkout_ru/item'
require 'checkout_ru/delivery'
require 'checkout_ru/user'

module CheckoutRu
  class Order < Entity
    module Status
      CREATED = 'CREATED'.freeze
      CANCELLED_BEFORE_SHIPMENT = 'CANCELLED_BEFORE_SHIPMENT'.freeze

      MAP = {
        created: CREATED,
        cancelled_before_shipment: CANCELLED_BEFORE_SHIPMENT
      }.freeze
    end

    property :goods
    property :delivery, required: true
    property :user, required: true
    property :comment
    property :shop_order_id, from: :shopOrderId
    property :payment_method, required: true, from: :paymentMethod
    property :forced_cost, from: :forcedCost

    coerce_key :goods, Item
    coerce_key :delivery, Delivery
    coerce_key :user, User

    def initialize(*)
      super
      self[:goods] ||= []
    end
  end
end
