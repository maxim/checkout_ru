require 'hashie'

module CheckoutRu
  class Entity < Hashie::Trash
    include Hashie::Extensions::Coercion
  end
end
