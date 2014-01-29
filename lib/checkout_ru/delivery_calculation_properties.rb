module CheckoutRu
  module DeliveryCalculationProperties
    def self.extended(base)
      base.property :cost
      base.property :min_delivery_term, :from => :minDeliveryTerm
      base.property :max_delivery_term, :from => :maxDeliveryTerm
      base.property :addresses
      base.property :codes
      base.property :costs
      base.property :deliveries
      base.property :min_terms, :from => :minTerms
      base.property :max_terms, :from => :maxTerms
      base.property :latitudes
      base.property :longitudes
      base.property :index_of_the_cheapest_terminal,
        :from => :indexOfTheCheapestTerminal
      base.property :additional_info, :from => :additionalInfo
    end
  end
end
