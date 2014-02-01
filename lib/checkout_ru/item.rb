require 'checkout_ru/entity'

module CheckoutRu
  class Item < Entity
    class << self
      def coerce(value)
        value.is_a?(Array) ?
          value.map{ |hash| new(hash) } :
          new(value)
      end
    end

    property :name,          :required => true
    property :code,          :required => true
    property :variant_code,  :required => true, :from => :variantCode
    property :quantity,      :required => true
    property :assessed_cost, :required => true, :from => :assessedCost
    property :pay_cost,      :required => true, :from => :payCost
    property :weight,        :required => true
  end
end
